const Server = @import("server.zig").Server;
const std = @import("std");

pub fn handleInitialize(
    responseFunc: *const fn (response: []const u8) void,
    _: []const u8,
) void {
    std.log.debug("handleInitialize", .{});
    responseFunc("Initialized with basic capabilities\n");
}
pub fn handleExit(
    _: *const fn (response: []const u8) void,
    _: []const u8,
) void {
    std.log.debug("handleExit\n", .{});
}
pub fn handleShutown(
    responseFunc: *const fn (response: []const u8) void,
    _: []const u8,
) void {
    std.log.debug("shutdown request", .{});
    responseFunc("Server shutting down\n");
}
pub fn handleUnknown(
    responseFunc: *const fn (response: []const u8) void,
    _: []const u8,
) void {
    std.log.debug("unknown request", .{});
    responseFunc("Unknown method\n");
}
