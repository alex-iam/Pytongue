const std = @import("std");

pub fn getTimestamp(buffer: []u8) []const u8 {
    const timestamp = std.time.timestamp();
    const epoch_seconds: u64 = @intCast(@mod(timestamp, 86400)); // Seconds since start of day
    const hours: u64 = @intCast(@divFloor(epoch_seconds, 3600));
    const minutes: u64 = @intCast(@divFloor(@mod(epoch_seconds, 3600), 60));
    const seconds: u64 = @intCast(@mod(epoch_seconds, 60));

    return std.fmt.bufPrint(
        buffer,
        "{:0>2}:{:0>2}:{:0>2}",
        .{ hours, minutes, seconds },
    ) catch unreachable;
}
