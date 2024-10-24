# Pytongue [![Tests](https://github.com/alex-korzh/Pytongue/actions/workflows/e2e-test.yml/badge.svg)](https://github.com/alex-korzh/Pytongue/actions/workflows/e2e-test.yml)
A project that aims to develop an LSP server for Python in Zig.

## Current state of the development:

- [x] Basic LSP server with generally compliant lifecycle
- [x] More checks for invalid methods, handler refactoring
- [ ] Parsing Python
- [ ] Connecting parsing to the server

## Building, running, testing

### Prerequisites:
 - Zig
 - (recommended, not necessary) just (https://github.com/casey/just)
 - Python (for testing only). Followed by poetry (https://python-poetry.org/)

### Environment variables:
 - `PYTONGUE_LOG` - an absolute path to a log file. At this point is necessary, as stdout logs confuse server.
 - `PYTONGUE_TEST_BINARY` - an absolute path to an app binary. Used in end-to-end tests. Not necessary, as the default value works in most cases.


Use justfile as a reference.

## Versioning

As there are multiple languages used in the project, with different build tools, and Zig build system is very unstable, a simple approach is used.

The current version format is stored in `version` file in the root of the project. It is in the semver (https://semver.org/) format.

## License

TBD
