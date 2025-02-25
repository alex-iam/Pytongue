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

const std = @import("std");
const lsp_specs = @import("lsp_specs");
const Position = lsp_specs.lsp_types.Position;
const SymbolKind = lsp_specs.enums.SymbolKind;
const Range = lsp_specs.lsp_types.Range;
const TextDocumentPositionParams = lsp_specs.params.TextDocumentPositionParams;

pub const Symbol = struct {
    name: []const u8, // has to be allocated
    kind: SymbolKind,
    position: Position,
    scope: ?*Scope,
    docstring: ?[]const u8,
    references: std.ArrayList(Position), // temporary, might switch to another solution later (map)

    // TODO create init
};

pub const Scope = struct {
    parent: ?*Scope,
    symbols: std.StringHashMap(Symbol),
    children: std.ArrayList(*Scope),
    allocator: std.mem.Allocator,
    uri: []const u8,
    range: ?Range,
    pub fn init(allocator: std.mem.Allocator, parent: ?*Scope, uri: []const u8, range: ?Range) Scope {
        return Scope{
            .parent = parent,
            .symbols = std.StringHashMap(Symbol).init(allocator),
            .children = std.ArrayList(*Scope).init(allocator),
            .allocator = allocator,
            .uri = uri,
            .range = range,
        };
    }
    pub fn deinit(self: *Scope) void {
        for (self.children.items) |child| {
            child.deinit();
            self.allocator.destroy(child);
        }
        self.children.deinit();
        var i = self.symbols.iterator();
        while (i.next()) |symbol| {
            // self.allocator.free(symbol.key_ptr.*);
            symbol.value_ptr.references.deinit();
        }
        self.symbols.deinit();
    }

    pub fn addSymbol(self: *Scope, symbol: Symbol) !void {
        // assuming symbol.scope is already set
        try self.symbols.put(symbol.name, symbol);
    }

    pub fn getSymbol(self: *Scope, name: []const u8) ?Symbol {
        return self.symbols.get(name);
    }

    pub fn addChildScope(self: *Scope, child_scope: *Scope) !void {
        child_scope.parent = self;
        try self.children.append(child_scope);
    }

    pub fn findInnermostScope(self: *Scope, pos: TextDocumentPositionParams) ?*Scope {
        // no range for scopes bigger than file
        // if range is not null, it's a file and its uri should match
        if ((self.range == null and
            (std.mem.eql(u8, self.uri, pos.textDocument.uri) or
            std.mem.startsWith(u8, pos.textDocument.uri, self.uri))) or
            (self.range != null and std.mem.eql(u8, self.uri, pos.textDocument.uri) and pos.position.inRange(self.range.?)))
        {
            for (self.children.items) |child| {
                const innermost = child.findInnermostScope(pos);
                if (innermost != null) {
                    return innermost;
                }
            }
            return self;
        }
        return null;
    }
};

pub fn CreateScopePtr(allocator: std.mem.Allocator, parent: ?*Scope, uri: []const u8, range: ?Range) !*Scope {
    const scope = try allocator.create(Scope);
    scope.* = .{
        .parent = parent,
        .symbols = std.StringHashMap(Symbol).init(allocator),
        .children = std.ArrayList(*Scope).init(allocator),
        .allocator = allocator,
        .uri = uri,
        .range = range,
    };
    return scope;
}

pub const SymbolTable = struct {
    rootScope: Scope,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, root_uri: []const u8) SymbolTable {
        return SymbolTable{
            .rootScope = Scope.init(allocator, null, root_uri, null),
            .allocator = allocator,
        };
    }
    pub fn deinit(self: *SymbolTable) void {
        self.rootScope.deinit();
    }

    pub fn findInnermostScope(self: *SymbolTable, position: TextDocumentPositionParams) ?*Scope {
        return self.rootScope.findInnermostScope(position);
    }
};
pub fn CreateSymbolTablePtr(allocator: std.mem.Allocator, root_uri: []const u8) !SymbolTable {
    const symbolTable = try allocator.create(SymbolTable);
    symbolTable.* = .{
        .rootScope = Scope.init(allocator, null, root_uri, null),
        .allocator = allocator,
    };
    return symbolTable;
}
