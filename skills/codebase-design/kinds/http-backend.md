# HTTP backend

Repositories that serve requests: REST APIs, backends for clients. Request-response, usually with a database, often with a few external providers.

## Rules

- **Keep transport at the entry point.** Parse and validate the request there, pass domain values to the core, and map its outcome to an HTTP response.

## API design

- Resources are nouns, operations are HTTP verbs. Give an action outside plain CRUD a resource or sub-resource that represents its result.
