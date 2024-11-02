const std = @import("std");
pub const parser_tests = @import("parser/tests.zig");

test {
    std.testing.refAllDecls(@This());
    std.testing.refAllDecls(parser_tests);
}
