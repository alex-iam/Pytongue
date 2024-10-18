const WorkspaceClientCapabilities = @import("workspace_client.zig").WorkspaceClientCapabilities;
const TextDocumentClientCapabilities = @import("text_document_client.zig").TextDocumentClientCapabilities;

pub const NotebookDocumentSyncClientCapabilities = struct {
    ///
    /// Whether implementation supports dynamic registration. If this is
    /// set to `true` the client supports the new
    /// `(TextDocumentRegistrationOptions & StaticRegistrationOptions)`
    /// return value for the corresponding server capability as well.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// The client supports sending execution summary data per cell.
    ///
    const executionSummarySupport: ?bool = null;
};

pub const NotebookDocumentClientCapabilities = struct {
    ///
    /// Capabilities specific to notebook document synchronization
    ///
    /// @since 3.17.0
    ///
    const synchronization: NotebookDocumentSyncClientCapabilities = undefined;
};

pub const ClientCapabilities = struct {
    ///
    /// Workspace specific client capabilities.
    ///
    const workspace: ?WorkspaceClientCapabilities = null;
    ///
    /// Text document specific client capabilities.
    ///
    const textDocument: ?TextDocumentClientCapabilities = null;
    ///
    /// Capabilities specific to the notebook document support.
    ///
    /// @since 3.17.0
    ///
    const notebookDocument: ?NotebookDocumentClientCapabilities = null;
};
