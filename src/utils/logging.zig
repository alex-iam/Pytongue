//! Temporary logging

const std = @import("std");
const time = @import("time.zig");

pub fn logMessageFn(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    var buffer: [12]u8 = undefined;
    const timestamp = time.getTimestamp(&buffer);

    const prefix = if (scope == .default) ": " else "(" ++ @tagName(scope) ++ "): ";
    const msg = std.fmt.allocPrint(
        std.heap.page_allocator,
        "[{s}] [{s}]{s}" ++ format ++ "\n",
        .{ timestamp, @tagName(level), prefix } ++ args,
    ) catch return;
    defer std.heap.page_allocator.free(msg);

    var log_file = openFile();
    log_file.writeAll(msg) catch unreachable;
    log_file.close();
}

pub fn openFile() std.fs.File {
    var log_file = std.fs.openFileAbsolute(
        "/home/alex/Documents/code/zig/pytongue/logs/all.log",
        .{ .mode = .write_only },
    ) catch unreachable;
    const stat = log_file.stat() catch unreachable;
    log_file.seekTo(stat.size) catch unreachable;
    return log_file;
}
