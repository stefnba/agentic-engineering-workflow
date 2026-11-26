# TypeScript

How to express the design rules in `SKILL.md` in TypeScript. Named tools are examples, not requirements.

| Concern                        | TypeScript                                                                                                                                                         |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Ports                          | A function type or `interface` declared by the core for the needed capability                                                                                      |
| Declaring adapters (grep test) | `implements` on a class, `satisfies` on an object, or an annotated function binding at composition                                                                 |
| Boundaries, cycles             | Check import direction in CI when it matters, e.g. with dependency-cruiser or eslint-plugin-boundaries. `exports` in `package.json` marks the public surface       |
| Strict types                   | Check seam types in CI with `strict` and `noUncheckedIndexedAccess`                                                                                                |
| Sum types                      | Discriminated unions with an exhaustive `switch` and a `never` check                                                                                               |
| Immutability                   | `readonly`, `as const`, `Readonly<T>`                                                                                                                              |
| Parsing at edges               | Validate untrusted data at entry points and adapters, e.g. with Zod or Valibot; the core uses plain types                                                          |
| Errors                         | Return a discriminated union when the caller branches on an outcome; throw a named error when no result can be produced. Use `T \| undefined` for ordinary absence |
| Composition root               | One `compose()` function; use the framework's container if it has one (NestJS), never build one                                                                    |
| Integration tests              | Test real adapters against real dependencies, e.g. Vitest or Jest with Testcontainers                                                                              |
