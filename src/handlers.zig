const Server = @import("server.zig").Server;
const std = @import("std");

pub fn handleInitialize(
    _: []const u8,
) []const u8 {
    std.log.debug("handleInitialize", .{});
    return "Initialized with basic capabilities\n";
}
pub fn handleExit(
    _: []const u8,
) []const u8 {
    std.log.debug("handleExit\n", .{});
    return "";
}
pub fn handleShutown(
    _: []const u8,
) []const u8 {
    std.log.debug("shutdown request", .{});
    return "Server shutting down\n";
}
pub fn handleUnknown(
    _: []const u8,
) []const u8 {
    std.log.debug("unknown request", .{});
    return "Unknown method\n";
}
