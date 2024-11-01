const std = @import("std");

const testing = std.testing;

const pytongue = @import("pytongue");

const ts = pytongue.ts;
const parser = @import("pytongue").parser;

test "parse-python-file" {
    const allocator = testing.allocator;

    const p = ts.TreeSitter.ts_parser_new().?;
    defer ts.TreeSitter.ts_parser_delete(p);

    _ = ts.TreeSitter.ts_parser_set_language(p, ts.tree_sitter_python());
    var workspace = parser.Workspace.init(
        "/home/alex/Documents/code/zig/pytongue",
        "/home/alex/Documents/code/zig/pytongue/.venv/bin/python",
        p,
        allocator,
    );
    defer workspace.deinit();
    _ = try workspace.parseFile("/home/alex/Documents/code/zig/pytongue/tests/assets/main.py", false);
}
