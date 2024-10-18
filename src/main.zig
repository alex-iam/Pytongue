const Server = @import("server.zig").Server;
const std = @import("std");
const logging = @import("utils/logging.zig");

pub const std_options = .{
    .logFn = logging.logMessageFn,
};

pub fn main() !void {
    Server.init();
    try Server.serve();
}
