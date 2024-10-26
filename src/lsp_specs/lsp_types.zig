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
pub const IntOrString = union(enum) {
    integer: i64,
    string: []const u8,
    pub fn jsonStringify(self: IntOrString, ws: anytype) !void {
        switch (self) {
            .integer => |value| try ws.write(value),
            .string => |value| try ws.write(value),
        }
    }
};

pub const LSPAny = union(enum) {
    LSPObject: LSPObject,
    LSPArray: LSPArray,
    string: []const u8,
    integer: i64,
    uinteger: u64,
    decimal: f64,
    boolean: bool,
    null: void,
    pub fn jsonStringify(self: LSPAny, ws: anytype) !void {
        switch (self) {
            .LSPObject => |value| try value.jsonStringify(ws),
            .LSPArray => |value| try ws.write(value),
            .string => |value| try ws.write(value),
            .integer => |value| try ws.write(value),
            .uinteger => |value| try ws.write(value),
            .decimal => |value| try ws.write(value),
            .boolean => |value| try ws.write(value),
            .null => |_| try ws.write(null),
        }
    }
};
pub const LSPObject = std.json.ArrayHashMap(LSPAny);
pub const LSPArray = []LSPAny;

pub const ObjectOrArray = union(enum) {
    LSPObject: LSPObject,
    LSPArray: LSPArray,
    pub fn jsonStringify(self: ObjectOrArray, ws: anytype) !void {
        switch (self) {
            .LSPObject => |value| try value.jsonStringify(ws),
            .LSPArray => |value| try ws.write(value),
        }
    }
};
pub const ProgressToken = IntOrString;
