const std = @import("std");
pub const IntOrString = union {
    integer: i64,
    string: []const u8,
};

pub const LSPAny = union {
    LSPObject: LSPObject,
    LSPArray: LSPArray,
    string: []const u8,
    integer: i64,
    uinteger: u64,
    decimal: f64,
    boolean: bool,
    null: void,
};
pub const LSPObject = std.StringHashMap(LSPAny);
pub const LSPArray = []LSPAny;

pub const ObjectOrArray = union {
    LSPObject: LSPObject,
    LSPArray: LSPArray,
};
pub const ProgressToken = IntOrString;
