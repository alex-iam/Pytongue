// This file is a part of Pytongue.
//
// Copyright (C) 2024 Oleksandr Korzh
//
// Pytongue is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Pytongue is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Pytongue. If not, see <https://www.gnu.org/licenses/>.

const std = @import("std");
const s = @import("state.zig");
const lsp_specs = @import("lsp_specs");
const m = lsp_specs.messages;
const ec = lsp_specs.error_codes;
const p = lsp_specs.params;
const t = lsp_specs.lsp_types;
const e = lsp_specs.enums;
const utils = @import("utils");
const parseValue = utils.parseValue;
const Config = utils.Config;

pub const ParsedRequestInfo = struct {
    id: ?t.IntOrString = undefined,
    request: std.json.Value = undefined,
    notificationMethod: ?e.NotificationMethod = undefined,
    requestMethod: ?e.RequestMethod = undefined,

    pub inline fn isRequest(self: ParsedRequestInfo) bool {
        return self.id != null or (self.requestMethod != null and self.notificationMethod == null);
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
        var parsedRequest = try parseValue(self.allocator, request);
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

    pub fn validateOnShutdown(self: *Handler) !void {
        if (self.stateManager.state == s.ServerState.Shutdown and self.parsedInfo.notificationMethod != e.NotificationMethod.exit) {
            return error.ServerShutdown;
        }
    }

    pub fn validateOnStarted(self: *Handler) !void {
        if (self.stateManager.state == s.ServerState.Started) {
            if (self.parsedInfo.requestMethod != e.RequestMethod.initialize and self.parsedInfo.notificationMethod != e.NotificationMethod.exit) {
                return error.ServerNotInitialized;
            }
        }
    }

    pub fn validate(self: *Handler) !void {
        try self.validateOnShutdown();
        try self.validateOnStarted();
    }

    pub fn handle(self: *Handler, request: []const u8) ?[]const u8 {
        self.parseRequst(request) catch |err| {
            std.log.debug("Request parsing failed: {any}", .{err});
            return self.makeError(ec.ParseError, "Request parsing failed");
        };
        defer {
            self.parsedInfo = undefined;
        }
        self.validate() catch |err| switch (err) {
            error.ServerShutdown => return self.makeError(
                ec.InvalidRequest,
                "Server is shutdown",
            ),
            error.ServerNotInitialized => return self.makeError(
                ec.InvalidRequest,
                "Server is not initialized",
            ),
        };
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
            }
            return null;
        }
    }
};
