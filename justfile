# set PYTONGUE_LOG there
set dotenv-load

build:
    zig build
run:
    zig build run
test:
    uv run pytest tests/e2e
retest: build test

patch:
    scripts/bump.sh patch
minor:
    scripts/bump.sh minor
major:
    scripts/bump.sh major