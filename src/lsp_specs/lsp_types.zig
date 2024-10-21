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
