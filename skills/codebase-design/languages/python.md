# Python

How to express the design rules in `SKILL.md` in Python. Named tools are examples, not requirements.

| Concern                        | Python                                                                                                                                                                      |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Ports                          | A callable type or `typing.Protocol` for the needed capability; use an ABC when shared behaviour is part of the interface                                                   |
| Declaring adapters (grep test) | Subclass the ABC, name the `Protocol` in the adapter's docstring, or annotate a callable binding at composition                                                             |
| Boundaries, cycles             | Check import direction in CI when it matters, e.g. with import-linter. `__all__` and leading underscores mark the public surface; neither prevents an import                |
| Strict types                   | Check seam types in CI with pyright strict or `mypy --strict`                                                                                                               |
| Sum types                      | `Enum`, `Literal`, unions with `match` and `assert_never`                                                                                                                   |
| Immutability                   | `@dataclass(frozen=True)`, tuples, `frozenset`                                                                                                                              |
| Multi-value returns            | A plain tuple only for ≤2 elements unpacked immediately at a single private call site; a `@dataclass` once the return crosses a module's interface or grows past two fields |
| Parsing at edges               | Validate untrusted data at entry points and adapters, e.g. with Pydantic; the core uses plain dataclasses                                                                   |
| Errors                         | Return a union when the caller branches on an outcome; raise a named exception when no result can be produced. Use `T \| None` for ordinary absence                         |
| Composition root               | A `compose()` or `build()` function; no DI container, no registration by import side effect                                                                                 |
| Integration tests              | Test real adapters against real dependencies, e.g. pytest with Testcontainers                                                                                               |

Notebooks are entry points or scratch; move logic shared by notebooks into a package.
