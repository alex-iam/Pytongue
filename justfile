# set PYTONGUE_LOG there
set dotenv-load
default:
  @just --choose

build:
    zig build
run arg:
    zig build run -- {{arg}}
ztest:
    rm -rf .zig-cache && zig build test --summary all
test: ztest
    uv run pytest tests/e2e
retest: build test

patch:
    scripts/bump.sh patch
minor:
    scripts/bump.sh minor
major:
    scripts/bump.sh major