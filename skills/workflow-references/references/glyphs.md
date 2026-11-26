# Glyphs

The one meaning each glyph carries in PR bodies, review comments, fix responses, gate messages,
and scan digests.
A glyph leads the line it qualifies; the words after it carry the meaning for parsers, the glyph
for the human scanning a thread.

Two GitHub callouts mark what the human must act on, and nothing else: `> [!IMPORTANT]` for an
escalation, `> [!CAUTION]` for a 🔴 one-way door.

| Glyph | Meaning                                                               |
| ----- | --------------------------------------------------------------------- |
| ✅    | passes, holds, fixed, adopted, closed, ready                          |
| ❌    | blocker, failing check, fixes required, still open                    |
| ⚠️    | concern, or a risk the human accepts                                  |
| ⚖️    | escalation: author and reviewer disagree, the human decides           |
| 💡    | design alternative                                                    |
| ❓    | design question only the human can settle                             |
| ↩️    | rebutted or rejected, with the evidence                               |
| 🛑    | stopped before judging, or a loop stopped after its last round        |
| 🟢    | two-way door: a revert restores the previous state                    |
| 🔴    | one-way door: data, a schema, a contract, or an external system moved |
| 🔺    | scan finding, high tier: can already misfire, or sits where the next change lands |
| 🔸    | scan finding, medium tier: every change through the code pays for it  |
| 🔹    | scan finding, low tier: real, and cheap to defer                      |
| 🎯    | pick now: becomes the next bundle                                     |
| 📋    | follow-up: becomes a backlog line                                     |
| 🗑️    | dropped                                                               |
