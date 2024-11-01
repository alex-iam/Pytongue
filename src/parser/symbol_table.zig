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

const Position = @import("../lsp_specs/lsp_types.zig").Position;
const SymbolKind = @import("../lsp_specs/enums.zig").SymbolKind;
const Location = @import("../lsp_specs/lsp_types.zig").Location;

pub const Symbol = struct {
    name: []const u8,
    kind: SymbolKind,
    position: Position,
    scope: *Scope,
    docstring: []const u8,
    references: std.ArrayList(Position), // temporary, might switch to another solution later (map)
};

pub const Scope = struct {
    parent: ?*Scope,
    symbols: std.StringHashMap(Symbol),
    children: std.ArrayList(*Scope),
    allocator: std.mem.Allocator,
    location: Location,
    pub fn init(allocator: *std.mem.Allocator, parent: ?*Scope) Scope {
        return Scope{
            .parent = parent,
            .symbols = std.StringHashMap(Symbol).init(allocator),
            .children = std.ArrayList(*Scope).init(allocator),
            .allocator = allocator,
        };
    }
    pub fn deinit(self: *Scope) void {
        for (self.children.items) |child| {
            child.deinit();
            self.allocator.free(child);
        }
        self.children.deinit();
        var i = self.symbols.iterator();
        while (i.next()) |symbol| {
            self.allocator.free(symbol.key_ptr.*);
        }
        self.symbols.deinit();
    }

    pub fn addSymbol(self: *Scope, symbol: Symbol) !void {
        try self.symbols.put(symbol.name, symbol);
    }

    pub fn getSymbol(self: *Scope, name: []const u8) ?*Symbol {
        return self.symbols.get(name);
    }

    pub fn addChildScope(self: *Scope, child_scope: *Scope) !void {
        try self.children.append(child_scope);
    }

    pub fn findInnermostScope(self: *Scope, position: Position) ?*Scope {
        if (position.inRange(self.location.range)) {
            for (self.children.items) |child| {
                const innermost = child.findInnermostScope(position);
                if (innermost != null) {
                    return innermost;
                }
            }
            return self;
        }
        return null;
    }
};

pub const SymbolTable = struct {
    rootScope: Scope,
    allocator: std.mem.Allocator,

    pub fn init(allocator: *std.mem.Allocator) SymbolTable {
        return SymbolTable{
            .rootScope = Scope.init(allocator, null),
            .allocator = allocator,
        };
    }
    pub fn deinit(self: *SymbolTable) void {
        self.rootScope.deinit();
    }

    pub fn findInnermostScope(self: *SymbolTable, position: Position) ?*Scope {
        return self.rootScope.findInnermostScope(position);
    }
};
