const Server = @import("server.zig").Server;
const std = @import("std");

pub fn handleInitialize(
    responseFunc: *const fn (response: []const u8) void,
    _: []const u8,
) void {
    std.log.debug("handleInitialize", .{});
    responseFunc("Initialized with basic capabilities");
}
pub fn handleExit(
    _: *const fn (response: []const u8) void,
    _: []const u8,
) void {
    std.log.debug("handleExit", .{});
}
pub fn handleShutown(
    responseFunc: *const fn (response: []const u8) void,
    _: []const u8,
) void {
    std.log.debug("shutdown request", .{});
    responseFunc("Server shutting down");
}
pub fn handleUnknown(
    responseFunc: *const fn (response: []const u8) void,
    _: []const u8,
) void {
    std.log.debug("unknown request", .{});
    responseFunc("Unknown method");
}
