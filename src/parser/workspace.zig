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
const TsDebug = @import("debug.zig");
const std = @import("std");
const p = @import("lsp_specs").params;
const SymbolTable = @import("symbol_table.zig").SymbolTable;
const CreateSymbolTablePtr = @import("symbol_table.zig").CreateSymbolTablePtr;

const FILE_SIZE_LIMIT = 5_000_000;

pub const PythonFile = struct {
    tree: *TreeSitter.TSTree,
    uri: []const u8,
    fileContents: []const u8, // allocate???

    pub fn init(
        fileContents: []const u8,
        parser: *TreeSitter.TSParser,
        uri: []const u8,
    ) !PythonFile {
        const tree = TreeSitter.ts_parser_parse_string(
            parser,
            null,
            fileContents.ptr,
            @intCast(fileContents.len),
        ) orelse return error.ParseError;
        return PythonFile{ .tree = tree, .uri = uri, .fileContents = fileContents };
    }
    pub fn update(self: *PythonFile, fileContents: []const u8, parser: *TreeSitter.TSParser) !void {
        self.fileContents = fileContents;
        self.tree = TreeSitter.ts_parser_parse_string(
            parser,
            self.tree,
            fileContents.ptr,
            @intCast(fileContents.len),
        ) orelse return error.ParseError;
    }

    pub fn printTree(self: PythonFile) void {
        TsDebug.printTree(self.tree);
    }
    pub fn deinit(self: PythonFile) void {
        TreeSitter.ts_tree_delete(self.tree);
    }
};

pub const Workspace = struct {
    rootDir: []const u8,
    pythonPath: []const u8,
    parser: *TreeSitter.TSParser,
    cachedFiles: std.StringHashMap(PythonFile),
    symbolTable: *SymbolTable,
    allocator: std.mem.Allocator,

    pub fn init(
        rootDir: []const u8,
        pythonPath: []const u8,
        parser: *TreeSitter.TSParser,
        allocator: std.mem.Allocator,
    ) !Workspace {
        std.log.debug("Workspace init", .{});
        return Workspace{
            .rootDir = rootDir,
            .pythonPath = pythonPath,
            .parser = parser,
            .cachedFiles = std.StringHashMap(PythonFile).init(allocator),
            .symbolTable = try CreateSymbolTablePtr(allocator, rootDir),
            .allocator = allocator,
        };
    }
    pub fn deinit(self: *Workspace) void {
        var i = self.cachedFiles.iterator();
        while (i.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            entry.value_ptr.deinit();
        }
        self.cachedFiles.deinit();
        self.symbolTable.deinit();
        self.allocator.destroy(self.symbolTable);
    }

    pub fn parseFile(self: *Workspace, filePath: []const u8, forceUpdate: bool) !PythonFile {
        var existingFile = self.cachedFiles.get(filePath);
        if (existingFile != null and !forceUpdate) {
            return self.cachedFiles.get(filePath).?;
        }
        const file = try std.fs.openFileAbsolute(filePath, .{ .mode = .read_only });
        defer file.close();
        const fileContents = try file.readToEndAlloc(self.allocator, FILE_SIZE_LIMIT);
        defer self.allocator.free(fileContents); // what if we need it in treesitter later??
        if (existingFile != null and forceUpdate) {
            try existingFile.?.update(fileContents, self.parser);
            return existingFile.?;
        } else {
            const pythonFile = try PythonFile.init(fileContents, self.parser);
            try self.cachedFiles.put(try self.allocator.dupe(u8, filePath), pythonFile);
            return pythonFile;
        }
    }

    // pub fn goToDefinition(self: *Workspace, info: p.TextDocumentPositionParams) ![]const u8 {}
};
