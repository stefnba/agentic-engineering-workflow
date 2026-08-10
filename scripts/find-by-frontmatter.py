#!/usr/bin/env python3
"""
find_by_frontmatter.py — filter Markdown files by YAML frontmatter fields.

No external dependencies (Python standard library only).

Supports a practical SUBSET of YAML commonly used in frontmatter:
  - flat scalars:        status: open
  - quoted scalars:      status: "open"
  - flow arrays:         tags: [a, b, c]
  - block arrays:        tags:
                            - a
                            - b
  - nested objects:      meta:
                            owner: alice
                            level: 2
  - dotted key access:   meta.owner

NOT supported (will be skipped or read as a plain string, not crash):
  - multi-line block scalars (| or >)
  - anchors/aliases (&foo, *foo)
  - flow-style nested maps ({a: 1, b: 2})
  - lists of mappings ( - name: x\n   val: y )

Usage:
  find_by_frontmatter.py <key> <value> [dir] [--contains] [--recursive/-r]

Examples:
  find_by_frontmatter.py status open .
  find_by_frontmatter.py agent explorer ./agents
  find_by_frontmatter.py meta.owner alice .
  find_by_frontmatter.py tags urgent . --contains
"""

import sys
import os
import glob
import argparse


def indent_of(line: str) -> int:
    return len(line) - len(line.lstrip(" "))


def strip_quotes(s: str) -> str:
    s = s.strip()
    if len(s) >= 2 and s[0] == s[-1] and s[0] in ("'", '"'):
        return s[1:-1]
    return s


def split_flow_list(s: str):
    """Split 'a, "b, c", d' into ['a', '"b, c"', 'd'] respecting quotes."""
    items, cur, quote = [], "", None
    for ch in s:
        if quote:
            cur += ch
            if ch == quote:
                quote = None
        elif ch in ("'", '"'):
            quote = ch
            cur += ch
        elif ch == ",":
            items.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur.strip():
        items.append(cur.strip())
    return items


def strip_inline_comment(s: str) -> str:
    """Cut a trailing ' # ...' comment, ignoring '#' inside quotes."""
    quote = None
    for i, ch in enumerate(s):
        if quote:
            if ch == quote:
                quote = None
        elif ch in ("'", '"'):
            quote = ch
        elif ch == "#" and (i == 0 or s[i - 1] in " \t"):
            return s[:i].rstrip()
    return s


def parse_scalar(s: str):
    s = strip_inline_comment(s.strip())
    if s == "":
        return None
    if s.startswith("[") and s.endswith("]"):
        inner = s[1:-1].strip()
        return [strip_quotes(x) for x in split_flow_list(inner)] if inner else []
    if s == "true":
        return True
    if s == "false":
        return False
    if s == "null" or s == "~":
        return None
    return strip_quotes(s)


def parse_block(lines, idx, indent):
    """Parse lines[idx:] at indentation >= indent. Returns (value, next_idx)."""
    result = None
    i, n = idx, len(lines)

    while i < n:
        line = lines[i]
        if not line.strip() or line.lstrip().startswith("#"):
            i += 1
            continue

        cur_indent = indent_of(line)
        if cur_indent < indent:
            break

        stripped = line.strip()

        if stripped.startswith("- "):
            if result is None:
                result = []
            item = stripped[2:].strip()
            result.append(parse_scalar(item))
            i += 1
            continue

        if result is None:
            result = {}
        if ":" not in stripped:
            i += 1
            continue

        key, _, rest = stripped.partition(":")
        key, rest = key.strip(), strip_inline_comment(rest.strip())

        if rest == "":
            # possible nested block — peek ahead for a deeper-indented line
            j = i + 1
            while j < n and not lines[j].strip():
                j += 1
            if j < n and indent_of(lines[j]) > cur_indent:
                value, next_i = parse_block(lines, j, indent_of(lines[j]))
                result[key] = value
                i = next_i
            else:
                result[key] = None
                i += 1
        else:
            result[key] = parse_scalar(rest)
            i += 1

    return result, i


def parse_frontmatter(text: str):
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    end = next((i for i in range(1, len(lines)) if lines[i].strip() == "---"), None)
    if end is None:
        return None
    value, _ = parse_block(lines, 1, 0)
    return value or {}


def get_path(data, dotted_key: str):
    cur = data
    for part in dotted_key.split("."):
        if isinstance(cur, dict) and part in cur:
            cur = cur[part]
        else:
            return None
    return cur


def main():
    ap = argparse.ArgumentParser(description="Filter Markdown files by frontmatter field.")
    ap.add_argument("key", help="frontmatter key, dotted for nested e.g. meta.owner")
    ap.add_argument("value", help="value to match")
    ap.add_argument("dir", nargs="?", default=".", help="directory to search (default: .)")
    ap.add_argument("--contains", action="store_true",
                     help="match if VALUE is an item inside an array field")
    ap.add_argument("--no-recursive", action="store_true",
                     help="only search the top-level directory, not subdirectories")
    args = ap.parse_args()

    pattern = os.path.join(args.dir, "*.md") if args.no_recursive else os.path.join(args.dir, "**", "*.md")

    for path in sorted(glob.glob(pattern, recursive=not args.no_recursive)):
        try:
            with open(path, "r", encoding="utf-8") as f:
                text = f.read()
        except OSError:
            continue

        data = parse_frontmatter(text)
        if not data:
            continue

        val = get_path(data, args.key)

        if args.contains:
            if isinstance(val, list) and args.value in val:
                print(path)
        else:
            if val == args.value:
                print(path)


if __name__ == "__main__":
    main()
