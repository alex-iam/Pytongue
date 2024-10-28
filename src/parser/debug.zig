// This file is a part of Pytongue.
//
// Copyright (C) 2024 Oleksandr Korzh
//
// Pytongue is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Pytongue is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Pytongue. If not, see <https://www.gnu.org/licenses/>.

const std = @import("std");
const TreeSitter = @import("tree-sitter.zig").TreeSitter;

fn printNode(node: TreeSitter.TSNode, depth: usize) void {
    const start = TreeSitter.ts_node_start_byte(node);
    const end = TreeSitter.ts_node_end_byte(node);
    const type_name = TreeSitter.ts_node_type(node);

    // Create indentation based on depth
    var indent_buf: [128]u8 = undefined;
    const indent = if (depth > 0) blk: {
        var i: usize = 0;
        while (i < @min(depth * 2, indent_buf.len)) : (i += 1) {
            indent_buf[i] = ' ';
        }
        break :blk indent_buf[0..i];
    } else "";

    // Print node information
    std.log.debug("{s}Node: {s} ({d}:{d})", .{
        indent,
        std.mem.span(type_name),
        start,
        end,
    });

    // Get child count
    const child_count = TreeSitter.ts_node_child_count(node);

    // Recursively print all children
    var i: usize = 0;
    while (i < child_count) : (i += 1) {
        const child = TreeSitter.ts_node_child(node, @intCast(i));
        printNode(child, depth + 1);
    }
}

pub fn printTree(tree: *TreeSitter.TSTree) void {
    const root_node = TreeSitter.ts_tree_root_node(tree);
    std.log.debug("Parsing tree:", .{});
    printNode(root_node, 0);
}
