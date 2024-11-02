const std = @import("std");

const testing = std.testing;

const parser = @import("parser");
const TreeSitter = parser.TreeSitter;
const tree_sitter_python = parser.tree_sitter_python;
const Workspace = parser.Workspace;

test "parse-python-file" {
    const allocator = testing.allocator;

    const p = TreeSitter.ts_parser_new().?;

    _ = TreeSitter.ts_parser_set_language(p, tree_sitter_python());
    var workspace = Workspace.init(
        "/tmp", // not used right now in Workspace
        "/usr/bin/python3",
        p,
        allocator,
    );
    const cwd = try std.fs.cwd().realpathAlloc(allocator, ".");
    const filePath = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ cwd, "tests/assets/main.py" });
    defer {
        TreeSitter.ts_parser_delete(p);
        workspace.deinit();
        allocator.free(cwd);
        allocator.free(filePath);
    }
    _ = try workspace.parseFile(filePath, false);
}
