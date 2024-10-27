const std = @import("std");

const testing = std.testing;

const TreeSitter = @cImport({
    @cInclude("tree_sitter/api.h");
});

extern "c" fn tree_sitter_python() *TreeSitter.TSLanguage;

test "parse-python-file" {
    const parser = TreeSitter.ts_parser_new();
    defer TreeSitter.ts_parser_delete(parser);

    _ = TreeSitter.ts_parser_set_language(parser, tree_sitter_python());

    const file = try std.fs.cwd().openFile("./tests/assets/main.py", .{});
    defer file.close();

    const stat = try file.stat(); // might be a race condition, but we're assuming file size won't change
    const source_code = try file.readToEndAlloc(testing.allocator, stat.size);
    defer testing.allocator.free(source_code);

    const tree = TreeSitter.ts_parser_parse_string(
        parser,
        null,
        source_code.ptr,
        @intCast(source_code.len),
    );
    defer TreeSitter.ts_tree_delete(tree);

    const root_node = TreeSitter.ts_tree_root_node(tree);
    try testing.expect(!TreeSitter.ts_node_is_null(root_node));
}
