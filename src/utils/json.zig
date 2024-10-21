const std = @import("std");

pub fn parseValue(allocator: std.mem.Allocator, data: []const u8) !std.json.Value {
    var stream = std.io.fixedBufferStream(data);
    var jr = std.json.reader(allocator, stream.reader());
    return std.json.Value.jsonParse(
        allocator,
        &jr,
        .{ .max_value_len = data.len },
    );
}
