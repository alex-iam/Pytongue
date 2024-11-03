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

/// Treesitter nodes we care about:
/// - `class_definition` followed by `name`:`identifier` (class name) is Symbol
///     `class_definition` is Scope
/// - `function_definition` followed by `name`:`identifier` (function name) is Symbol
///    `function_definition` is Scope
/// - `assignment` followed by `left`:`identifier` (variable name) is Symbol
/// `module` is Scope (file)
///
/// Parsing strategy:
/// - Determine where file belongs in the symbol table, assuming every directory is a scope
/// - Create new scope, write ts_node_start_byte and ts_node_end_byte from root node as range
/// (assuming root node is `module`)
/// - For every node:
///    - If node is `class_definition`, `function_definition` or `assignment`:
///       - Create new Scope, look for `identifier` in children
///       - If found, create new Symbol, write ts_node_start_byte and ts_node_end_byte as range
///
pub fn ParseASTIntoST(file: *PythonFile, st: *SymbolTable) !void {
    const rootNode = TreeSitter.ts_tree_root_node(file.tree);
    parseTSNode(st, rootNode);
}
