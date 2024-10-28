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

// As a first step, working with one file instead of a workspace.

const TreeSitter = @import("tree-sitter.zig").TreeSitter;
const TsDebug = @import("debug.zig");
const std = @import("std");

const Config = struct {
    pythonPath: []const u8,
};

pub const PythonFile = struct {
    tree: *TreeSitter.TSTree,

    pub fn init(fileContents: []const u8, parser: *TreeSitter.TSParser) !PythonFile {
        const tree = TreeSitter.ts_parser_parse_string(
            parser,
            null,
            fileContents.ptr,
            @intCast(fileContents.len),
        ) orelse return error.ParseError;
        return PythonFile{ .tree = tree };
    }
    pub fn printTree(self: PythonFile) void {
        TsDebug.printTree(self.tree);
    }
    pub fn deinit(self: PythonFile) void {
        TreeSitter.ts_tree_delete(self.tree);
    }
};
