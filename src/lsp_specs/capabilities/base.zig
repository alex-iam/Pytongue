pub const BaseDynamicRegistration = struct {
    const dynamicRegistration: ?bool = null;
};

pub const BaseRefreshSupport = struct {
    const refreshSupport: ?bool = null;
};
pub const BaseLinkSupport = struct {
    ///
    /// Whether declaration supports dynamic registration. If this is set to `true`
    /// the client supports the new `DeclarationRegistrationOptions` return value
    /// for the corresponding server capability as well.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// The client supports additional metadata in the form of declaration links.
    ///
    const linkSupport: ?bool = null;
};
