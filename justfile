# set PYTONGUE_LOG there
set dotenv-load
default:
  @just --choose

build:
    zig build
run arg:
    zig build run -- {{arg}}
ztest:
    zig build test --summary all
test: ztest
    uv run pytest tests/e2e
retest: build test

patch:
    scripts/bump.clj patch
minor:
    scripts/bump.clj minor
major:
    scripts/bump.clj major
