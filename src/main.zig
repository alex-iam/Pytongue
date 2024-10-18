const Server = @import("server.zig").Server;
const std = @import("std");
const logging = @import("utils/logging.zig");

pub const std_options = .{
    .logFn = logging.logMessageFn,
};

pub fn main() !void {
    logging.log_file = try std.fs.openFileAbsolute("/home/alex/Documents/code/zig/pytongue/logs/all.log", .{ .mode = .write_only });
    const stat = try logging.log_file.stat();
    try logging.log_file.seekTo(stat.size);
    defer logging.log_file.close();

    Server.init();
    try Server.serve();
}
