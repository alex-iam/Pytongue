# Pytongue [![Tests](https://github.com/alex-korzh/Pytongue/actions/workflows/e2e-test.yml/badge.svg)](https://github.com/alex-korzh/Pytongue/actions/workflows/e2e-test.yml) [![builds.sr.ht status](https://builds.sr.ht/~alex-iam/Pytongue.svg)](https://builds.sr.ht/~alex-iam/Pytongue?)
A project that aims to develop an LSP server for Python in Zig.

## Current state of the development, plans:

- [x] Basic LSP server with generally compliant lifecycle
- [x] More checks for invalid methods, handler refactoring
- [x] Parsing Python to AST (tree-sitter)
- [ ] Building symbol table
- [ ] Implementing basic code actions
- [ ] Connecting those to the server

At some point: move lsp specs into a separate module (when mature enough)

### Considerations regarding parsing solutions

After doing some research, decided that the best course of actions would be
to start with tree-sitter, but continue evaluating other options.

## Building, running, testing

### Prerequisites:
 - Zig
 - (recommended, not necessary) just (https://github.com/casey/just)
 - Python (for testing only). `uv` is used to manage dependencies.

(TODO: measure uv vs pip in github actions)

### On external dependencies

Currently they are just thrown in ./lib as a static libraries, need to think whether submodule them or download and build every rebuild (or rather on providing a special flag)

### Environment variables:
 - `PYTONGUE_LOG` - an absolute path to a log file. At this point is necessary, as stdout logs confuse server.
 - `PYTONGUE_TEST_BINARY` - an absolute path to an app binary. Used in end-to-end tests. Not necessary, as the default value works in most cases.


Use justfile as a reference.

## Versioning

As there are multiple languages used in the project, with different build tools, and Zig build system is very unstable, a simple approach is used.

The current version format is stored in `version` file in the root of the project. It is in the semver (https://semver.org/) format.

## License

This program statically links the following MIT‑licensed components:

- tree‑sitter — see licenses/LICENSE.tree‑sitter
- tree‑sitter‑python — see licenses/LICENSE.tree‑sitter‑python


For the source code license, see LICENSE.md
