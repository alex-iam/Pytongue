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

pub fn readEntireFile(allocator: std.mem.Allocator, filename: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    errdefer allocator.free(buffer);

    const bytes_read = try file.readAll(buffer);
    if (bytes_read != file_size) {
        return error.UnexpectedEOF;
    }

    return buffer;
}
