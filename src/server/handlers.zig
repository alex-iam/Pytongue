const std = @import("std");
const s = @import("state.zig");
const m = @import("../lsp_specs/messages.zig");
const ec = @import("../lsp_specs/error_codes.zig");
const p = @import("../lsp_specs/params.zig");
const t = @import("../lsp_specs/lsp_types.zig");
const e = @import("../lsp_specs/enums.zig");
const j = @import("../utils/json.zig");
const Config = @import("../utils/config.zig").Config;

pub const ParsedRequestInfo = struct {
    id: ?t.IntOrString = undefined,
    request: std.json.Value = undefined,
    notificationMethod: ?e.NotificationMethod = undefined,
    requestMethod: ?e.RequestMethod = undefined,

    pub inline fn isRequest(self: ParsedRequestInfo) bool {
        return self.id != null and self.requestMethod != null and self.notificationMethod == null;
    }
};

pub const Handler = struct {
    stateManager: *s.StateManager,
    allocator: std.mem.Allocator,
    config: *Config,
    parsedInfo: ParsedRequestInfo = undefined,

    pub fn init(stateManager: *s.StateManager, allocator: std.mem.Allocator, config: *Config) Handler {
        return Handler{
            .stateManager = stateManager,
            .allocator = allocator,
            .config = config,
        };
    }

    pub fn makeResponse(self: *Handler, response: anytype) []const u8 {
        var strResponse = std.ArrayList(u8).init(self.allocator);
        // FIXME
        std.json.stringify(response, .{}, strResponse.writer()) catch unreachable;
        return strResponse.toOwnedSlice() catch unreachable;
    }

    pub fn makeError(self: *Handler, code: i32, message: []const u8) []const u8 {
        return self.makeResponse(m.ResponseMessage{
            .id = self.parsedInfo.id,
            .@"error" = m.ResponseError{
                .code = code,
                .message = message,
            },
        });
    }

    pub fn handleRequest(self: *Handler) []const u8 {
        if (self.parsedInfo.requestMethod) |method| {
            std.log.debug("received a <request> with method {s}", .{@tagName(method)});
            switch (method) {
                e.RequestMethod.initialize => {
                    self.stateManager.initServer() catch {
                        return self.makeError(ec.InvalidRequest, "Method not allowed");
                    };
                    const response = m.ResponseMessage{
                        .id = self.parsedInfo.id,
                        .result = p.InitializeResult{
                            .capabilities = .{},
                            .serverInfo = .{
                                .name = self.config.projectName,
                                .version = self.config.projectVersion,
                            },
                        },
                    };
                    return self.makeResponse(response);
                },
                e.RequestMethod.shutdown => {
                    self.stateManager.shutdownServer() catch {
                        return self.makeError(ec.InvalidRequest, "Method not allowed");
                    };
                    std.log.debug("server shutting down", .{});
                    return self.makeResponse(m.ResponseMessage{ .id = self.parsedInfo.id, .result = null });
                },
            }
        } else { // not found in enum
            return self.makeError(ec.MethodNotFound, "Unknown method");
        }
    }

    pub fn parseId(_: *Handler, id: ?std.json.Value) ?t.IntOrString {
        if (id) |id_v| {
            switch (id_v) {
                .integer => |v| return t.IntOrString{ .integer = v },
                .string => |v| return t.IntOrString{ .string = v },
                else => {},
            }
        }
        return null;
    }

    pub fn parseRequst(self: *Handler, request: []const u8) !void {
        var parsedRequest = try j.parseValue(self.allocator, request);
        self.parsedInfo = ParsedRequestInfo{
            .id = self.parseId(parsedRequest.object.get("id")),
            .request = parsedRequest,
            .notificationMethod = std.meta.stringToEnum(
                e.NotificationMethod,
                parsedRequest.object.get("method").?.string,
            ),
            .requestMethod = std.meta.stringToEnum(
                e.RequestMethod,
                parsedRequest.object.get("method").?.string,
            ),
        };
    }

    pub fn handle(self: *Handler, request: []const u8) ?[]const u8 {
        self.parseRequst(request) catch |err| {
            std.log.debug("Request parsing failed: {any}", .{err});
            return self.makeError(ec.ParseError, "Request parsing failed");
        };
        defer {
            self.parsedInfo = undefined;
        }
        // if (self.stateManager.state == s.ServerState.Shutdown) {
        //     return self.makeError(ec.InvalidRequest, "Server is shutdown");
        // }
        // RequestMessage
        if (self.parsedInfo.isRequest()) {
            return self.handleRequest();
        } else { // NotificationMessage
            if (self.parsedInfo.notificationMethod) |method| {
                std.log.debug("received a <notification> with method {s}", .{@tagName(method)});
                switch (method) {
                    e.NotificationMethod.exit => {
                        self.stateManager.exitServer() catch {
                            std.log.debug("server exiting unexpectedly", .{});
                            std.process.exit(1);
                        };
                        std.log.debug("server exiting gracefully", .{});
                    },
                    e.NotificationMethod.initialized => {},
                }
            } else {
                std.log.debug("A notification without a method", .{});
                return self.makeError(ec.MethodNotFound, "Unknown method");
            }
            return null;
        }
    }
};
