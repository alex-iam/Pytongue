const std = @import("std");

pub fn openFileAppend(filename: []const u8) std.fs.File {
    var file = std.fs.openFileAbsolute(
        filename,
        .{ .mode = .write_only },
    ) catch unreachable;
    const stat = file.stat() catch unreachable;
    file.seekTo(stat.size) catch unreachable;
    return file;
}
