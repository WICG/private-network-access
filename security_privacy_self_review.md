# Security and Privacy Self-Review: CORS-RFC1918

Based on the W3C TAG's
[questionnaire](https://www.w3.org/TR/security-privacy-questionnaire/).

# 1. What information might this feature expose to Web sites or other parties, and for what purposes is that exposure necessary?

As currently specified, `document.addressSpace` can reveal some details
about the IP address from which a document was loaded. Its purpose
is twofold: feature detection and easier testability. Its removal is under
active consideration: see
[issue #21](https://github.com/WICG/cors-rfc1918/issues/21).

# 2. Is this specification exposing the minimum amount of information necessary to power the feature?

Yes, apart from the above.

# 3. How does this specification deal with personal information or personally-identifiable information or information derived thereof?

It does not.

# 4. How does this specification deal with sensitive information?

It does not.

# 5. Does this specification introduce new state for an origin that persists across browsing sessions?

Yes, in the form of new entries in the CORS pre-flight cache.

# 6. What information from the underlying platform, e.g. configuration data, is exposed by this specification to an origin?

`document.addressSpace` can reveal some details about network configuration,
though it should really only ever be interesting to intranet websites:
knowing that example.org is `public` in the eyes of a client is not particularly
interesting.

It might be a problem if it reveals that a client loaded a
particular website over a non-public proxy, such as:

* an ssh tunnel
* a network inspection tool such as [Fiddler](https://telerik.com/fiddler)
* a corporate proxy

# 7. Does this specification allow an origin access to sensors on a user’s device?

No.

# 8. What data does this specification expose to an origin? Please also document what data is identical to data exposed by other features, in the same or different contexts.

`document.addressSpace`, as explained in the responses to questions 1 and 6,
exposes some amount of information about network configuration to origins.

# 9. Does this specification enable new script execution/loading mechanisms?

No.

# 10. Does this specification allow an origin to access other devices?

No, instead it restricts the ability of origins to access local network devices.

# 11. Does this specification allow an origin some measure of control over a user agent’s native UI?

No.

# 12. What temporary identifiers might this this specification create or expose to the web?

None.

# 13. How does this specification distinguish between behavior in first-party and third-party contexts?

Third-party iframes are treated distinctly from the first party embedder: even
if the first party is served from non-public address space, only the third
party's address space is considered when applying CORS-RFC1918 checks to
requests made by the third-party iframe.

Third-party scripts are not treated distinctly. In the case of
`document.addressSpace`, this could reveal some information about network
configuration to third parties. There seems to be no particular reason to treat
third party scripts differently when checking outgoing requests, however.

One area of discussion is
whether or not to treat sandboxed iframes as `public`:
https://github.com/WICG/cors-rfc1918/issues/26. It seems a good idea to do so,
enabling web developers to include third-party content on non-public websites
without allowing it to poke at non-public resources.

# 14. How does this specification work in the context of a user agent’s Private Browsing or "incognito" mode?

It works no differently.

# 15. Does this specification have a "Security Considerations" and "Privacy Considerations" section?

Yes.

# 16. Does this specification allow downgrading default security characteristics?

It does not. While the CORS part might be interpreted as doing so, that is only
valid against a baseline of higher security requirements. On the whole, the
specification is only security-positive, and relaxes no security requirements
compared to the status quo.

# 17. What should this questionnaire have asked?

Nothing else I can think of that would be generic enough to warrant inclusion!
