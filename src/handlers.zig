const Server = @import("server/server.zig").Server;
const std = @import("std");
const StateManager = @import("server/state.zig").StateManager;
const m = @import("lsp_specs/messages.zig");
const ec = @import("lsp_specs/error_codes.zig");
const p = @import("lsp_specs/params.zig");

pub fn makeResponse(response: anytype, allocator: std.mem.Allocator) []const u8 {
    var strResponse = std.ArrayList(u8).init(allocator);
    // FIXME
    std.json.stringify(response, .{}, strResponse.writer()) catch unreachable;
    return strResponse.toOwnedSlice() catch unreachable;
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
        if (std.mem.eql(u8, parsedRequest.object.get("method").?.string, "initialize")) {
            response = m.ResponseMessage{
                .id = id.string,
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
        } else { // not initialize
            response = m.ResponseMessage{
                .id = id.string,
                .@"error" = m.ResponseError{
                    .code = ec.MethodNotFound,
                    .message = "Unknown method",
                },
            };
            return makeResponse(response, allocator);
        }
    } else { // NotificationMessage
        return null;
    }
}
