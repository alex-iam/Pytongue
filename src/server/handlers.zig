const Server = @import("server.zig").Server;
const std = @import("std");
const s = @import("state.zig");
const m = @import("../lsp_specs/messages.zig");
const ec = @import("../lsp_specs/error_codes.zig");
const p = @import("../lsp_specs/params.zig");
const t = @import("../lsp_specs/lsp_types.zig");
const e = @import("../lsp_specs/enums.zig");
const j = @import("../utils/json.zig");

pub fn makeResponse(response: anytype, allocator: std.mem.Allocator) []const u8 {
    var strResponse = std.ArrayList(u8).init(allocator);
    // FIXME
    std.json.stringify(response, .{}, strResponse.writer()) catch unreachable;
    return strResponse.toOwnedSlice() catch unreachable;
}

pub fn makeError(code: i32, id: ?t.IntOrString, message: []const u8, allocator: std.mem.Allocator) []const u8 {
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

pub fn handleRequest(
    id: std.json.Value,
    parsedRequest: std.json.Value,
    stateManager: *s.StateManager,
    allocator: std.mem.Allocator,
) []const u8 {
    var parsedId: t.IntOrString = undefined;
    switch (id) {
        .integer => |v| parsedId = t.IntOrString{ .integer = v },
        .string => |v| parsedId = t.IntOrString{ .string = v },
        else => {},
    }
    if (std.meta.stringToEnum(e.RequestMethod, parsedRequest.object.get("method").?.string)) |method| {
        switch (method) {
            e.RequestMethod.initialize => {
                const response = m.ResponseMessage{
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
            e.RequestMethod.shutdown => {
                stateManager.shutdownServer() catch unreachable; // TODO return error
                return makeResponse(m.ResponseMessage{ .id = parsedId, .result = null }, allocator);
            },
        }
    } else { // not found in enum
        return makeError(ec.MethodNotFound, parsedId, "Unknown method", allocator);
    }
}

pub fn baseHandler(stateManager: *s.StateManager, allocator: std.mem.Allocator, request: []const u8) ?[]const u8 {
    var parsedRequest = j.parseValue(
        allocator,
        request,
    ) catch |err| {
        std.log.debug("{any}", .{err});
        return makeError(ec.ParseError, null, "Request parsing failed", allocator);
    };
    // TODO pass ID's
    if (stateManager.state == s.ServerState.Shutdown) {
        return makeError(ec.InvalidRequest, null, "Server is shutdown", allocator);
    }
    // AND method != initialize
    // if (stateManager.state == s.ServerState.Started) {
    //     return makeError(ec.ServerNotInitialized, null, "Server is not initialized", allocator);
    // }
    // RequestMessage
    if (parsedRequest.object.get("id")) |id| {
        return handleRequest(id, parsedRequest, stateManager, allocator);
    } else { // NotificationMessage
        if (std.meta.stringToEnum(
            e.NotificationMethod,
            parsedRequest.object.get("method").?.string,
        )) |method| {
            switch (method) {
                e.NotificationMethod.exit => {
                    stateManager.exitServer() catch {
                        std.process.exit(1);
                    };
                },
                e.NotificationMethod.initialized => {},
            }
        } else {
            return makeError(ec.MethodNotFound, null, "Unknown method", allocator);
        }
        return null;
    }
}
