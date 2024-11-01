const std = @import("std");

const testing = std.testing;

const pytongue = @import("pytongue");

const ts = pytongue.ts;
const parser = @import("pytongue").workspace;

test "parse-python-file" {
    const allocator = testing.allocator;

    const p = ts.TreeSitter.ts_parser_new().?;

    _ = ts.TreeSitter.ts_parser_set_language(p, ts.tree_sitter_python());
    // FIXME
    var workspace = parser.Workspace.init(
        "/home/alex/Documents/code/zig/pytongue",
        "/home/alex/Documents/code/zig/pytongue/.venv/bin/python",
        p,
        allocator,
    );
    const cwd = try std.fs.cwd().realpathAlloc(allocator, ".");
    const filePath = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ cwd, "tests/assets/main.py" });
    defer {
        ts.TreeSitter.ts_parser_delete(p);
        workspace.deinit();
        allocator.free(cwd);
        allocator.free(filePath);
    }
    _ = try workspace.parseFile(filePath, false);
}
