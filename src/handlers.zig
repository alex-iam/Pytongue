const Server = @import("server/server.zig").Server;
const std = @import("std");
const StateManager = @import("server/state.zig").StateManager;
const m = @import("lsp_specs/messages.zig");
const ec = @import("lsp_specs/error_codes.zig");
const p = @import("lsp_specs/params.zig");
const t = @import("lsp_specs/lsp_types.zig");
const e = @import("lsp_specs/enums.zig");

pub fn makeResponse(response: anytype, allocator: std.mem.Allocator) []const u8 {
    var strResponse = std.ArrayList(u8).init(allocator);
    // FIXME
    std.json.stringify(response, .{}, strResponse.writer()) catch unreachable;
    return strResponse.toOwnedSlice() catch unreachable;
}

pub fn makeError(code: i32, id: t.IntOrString, message: []const u8, allocator: std.mem.Allocator) []const u8 {
    return makeResponse(
        m.ResponseMessage{
            .id = id,
            .@"error" = m.ResponseError{
                .code = code,
                .message = message,
            },
        },
        allocator,
    );
}

pub fn baseHandler(stateManager: *StateManager, allocator: std.mem.Allocator, request: []const u8) ?[]const u8 {
    var response: m.ResponseMessage = undefined;
    var stream = std.io.fixedBufferStream(request);
    var jr = std.json.reader(allocator, stream.reader());
    var parsedRequest = std.json.Value.jsonParse(
        allocator,
        &jr,
        .{ .max_value_len = request.len },
    ) catch |err| {
        std.log.debug("{any}", .{err});
        response = m.ResponseMessage{
            .id = null,
            .@"error" = m.ResponseError{
                .code = ec.ParseError,
                .message = "Request parsing failed",
            },
        };
        return makeResponse(response, allocator);
    };
    // RequestMessage
    if (parsedRequest.object.get("id")) |id| {
        var parsedId: t.IntOrString = undefined;
        switch (id) {
            .integer => |v| parsedId = t.IntOrString{ .integer = v },
            .string => |v| parsedId = t.IntOrString{ .string = v },
            else => {},
        }
        if (std.meta.stringToEnum(e.MessageMethod, parsedRequest.object.get("method").?.string)) |method| {
            switch (method) {
                e.MessageMethod.initialize => {
                    response = m.ResponseMessage{
                        .id = parsedId,
                        .result = p.InitializeResult{
                            .capabilities = .{},
                            .serverInfo = .{
                                .name = "Pytongue",
                                .version = "0.1.0",
                            },
                        },
                    };
                    stateManager.initServer() catch unreachable; // TODO return error
                    return makeResponse(response, allocator);
                },
                else => {
                    return makeError(ec.MethodNotFound, parsedId, "Unknown method", allocator);
                },
            }
        } else { // not found in enum

            return makeError(ec.MethodNotFound, parsedId, "Unknown method", allocator);
        }
    } else { // NotificationMessage
        return null;
    }
}
