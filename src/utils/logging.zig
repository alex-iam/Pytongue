const std = @import("std");
const time = @import("time.zig");

pub var log_file: std.fs.File = undefined;

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

    // Write the formatted message to the file
    log_file.writeAll(msg) catch return;
}
