// This file is a part of Pytongue.
//
// Copyright (C) 2024, 2025 Oleksandr Korzh
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
const std = @import("std");
const TSTree = TreeSitter.TSTree;
const TSNode = TreeSitter.TSNode;

const SymbolTable = @import("symbol_table.zig").SymbolTable;
const Symbol = @import("symbol_table.zig").Symbol;
const Scope = @import("symbol_table.zig").Scope;
const CreateScopePtr = @import("symbol_table.zig").CreateScopePtr;
const PythonFile = @import("workspace.zig").PythonFile;
const Range = @import("lsp_specs").lsp_types.Range;
const Position = @import("lsp_specs").lsp_types.Position;
const SymbolKind = @import("lsp_specs").enums.SymbolKind;

const TSSymbolKind = enum { Class, Function, Assignment, Identifier, Module, Other };

fn classifyNodeType(nodeType: []const u8) TSSymbolKind {
    if (std.mem.eql(u8, nodeType, "class_definition")) {
        return .Class;
    } else if (std.mem.eql(u8, nodeType, "function_definition")) {
        return .Function;
    } else if (std.mem.eql(u8, nodeType, "assignment")) {
        return .Assignment;
    } else if (std.mem.eql(u8, nodeType, "identifier")) {
        return .Identifier;
    } else if (std.mem.eql(u8, nodeType, "module")) {
        return .Module;
    } else {
        return .Other;
    }
}

fn getRangeFromTSNode(node: TSNode) Range {
    const startPoint = TreeSitter.ts_node_start_point(node);
    const endPoint = TreeSitter.ts_node_end_point(node);

    return .{ .{ startPoint.row, startPoint.column }, .{ endPoint.row, endPoint.column } };
}

fn getNodeUnitName(node: TSNode, fileContents: []const u8) []const u8 {
    const nameNode = TreeSitter.ts_node_child_by_field_name(node, "name", "name".len);
    const start = TreeSitter.ts_node_start_byte(nameNode);
    const end = TreeSitter.ts_node_end_byte(nameNode);

    return fileContents[start..end];
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
fn parseTSNode(st: *SymbolTable, node: TSNode, currentScope: ?*Scope, fileUri: []const u8, fileContents: []const u8) !void {
    const nodeTypeStr = TreeSitter.ts_node_type(node);
    const nodeType = classifyNodeType(nodeTypeStr);
    var scope = currentScope orelse &st.rootScope;
    var nextNode: ?TSNode = null;

    switch (nodeType) {
        .Module => {
            scope.range = getRangeFromTSNode(node);
            scope.uri = fileUri;
        },
        .Class, .Function => {
            const name = getNodeUnitName(node, fileContents);
            // TODO NEXT NODE IS node->body
            const range = getRangeFromTSNode(node);
            const newScope = try CreateScopePtr(
                st.allocator,
                scope,
                fileUri,
                range,
            );
            const symbolKind = if (nodeType == .Class) SymbolKind.Class else SymbolKind.Function;
            const symbol = Symbol{
                .name = try st.allocator.dupe(u8, name),
                .kind = symbolKind,
                .position = range.start,
                .scope = newScope,
                .docstring = null,
                .references = std.ArrayList(Position).init(st.allocator),
            };
            try scope.addSymbol(symbol);
            try scope.addChildScope(newScope);
            scope = newScope;
        },
        .Assignment => {},
    }

    const child_count = TreeSitter.ts_node_child_count(node);
    var i: usize = 0;
    while (i < child_count) : (i += 1) {
        const child = TreeSitter.ts_node_child(node, @intCast(i));
        parseTSNode(st, child, scope, fileUri);
    }
    // Note: IF new scope was created,
    // return to the patent scope.
}

pub fn ParseASTIntoST(file: *PythonFile, st: *SymbolTable) !void {
    const rootNode = TreeSitter.ts_tree_root_node(file.tree);
    parseTSNode(st, rootNode, null, file.uri, file.fileContents);
}
