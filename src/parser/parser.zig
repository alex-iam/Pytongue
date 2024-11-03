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

const TreeSitter = @import("treesitter.zig").TreeSitter;
const TSTree = TreeSitter.TSTree;
const TSNode = TreeSitter.TSNode;

const SymbolTable = @import("symbol_table.zig").SymbolTable;
const PythonFile = @import("workspace.zig").PythonFile;

fn parseTSNode(st: *SymbolTable, node: TSNode) !void {
    const child_count = TreeSitter.ts_node_child_count(node);
    var i: usize = 0;
    while (i < child_count) : (i += 1) {
        const child = TreeSitter.ts_node_child(node, @intCast(i));
        parseTSNode(st, child);
    }
}

pub fn ParseASTIntoST(file: *PythonFile, st: *SymbolTable) !void {
    const rootNode = TreeSitter.ts_tree_root_node(file.tree);
    parseTSNode(st, rootNode);
}
