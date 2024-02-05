# Security and Privacy Self-Review: Private Network Access

Based on the W3C TAG's
[questionnaire](https://www.w3.org/TR/security-privacy-questionnaire/).

## 1. What information might this feature expose to Web sites or other parties, and for what purposes is that exposure necessary?

Documents might be able to infer whether they were loaded from `public`,
`private` or `local` IP address by observing whether they can successfully load
a well-known subresource from the private network or localhost. This is largely
unavoidable by design: this specification aims to alter user agent behavior
differentially based on the IP address which served the main resource.

This can also arise when a client loaded a resource over a non-public proxy,
such as:

* an ssh tunnel
* a network inspection tool such as [Fiddler](https://telerik.com/fiddler)
* a corporate proxy

Timing attacks might also be possible, though no concrete scenario has yet been
laid out.

See #41 for a discussion of these points.

Also, in the prelights we send the initiator's `Origin`.  This was necessary to give servers in the private network enough information
to decide whether they should allow the requests from public.

## 2. Is this specification exposing the minimum amount of information necessary to power the feature?

Yes, apart from the above.

## 3. How does this specification deal with personal information or personally-identifiable information or information derived thereof?

It does not.

## 4. How does this specification deal with sensitive information?

It does not.

## 5. Does this specification introduce new state for an origin that persists across browsing sessions?

Yes, in the form of new entries in the CORS pre-flight cache.

## 6. What information from the underlying platform, e.g. configuration data, is exposed by this specification to an origin?

See question 1.

## 7. Does this specification allow an origin access to sensors on a user’s device?

No.

## 8. What data does this specification expose to an origin? Please also document what data is identical to data exposed by other features, in the same or different contexts.

See question 1.

## 9. Does this specification enable new script execution/loading mechanisms?

No.

## 10. Does this specification allow an origin to access other devices?

No, instead it restricts the ability of origins to access local network devices.

## 11. Does this specification allow an origin some measure of control over a user agent’s native UI?

No.

## 12. What temporary identifiers might this this specification create or expose to the web?

None.

## 13. How does this specification distinguish between behavior in first-party and third-party contexts?

Third-party iframes are treated distinctly from the first party embedder: even
if the first party is served from non-public address space, only the third
party's address space is considered when applying private network request checks
to requests made by the third-party iframe.

Third-party scripts are not treated distinctly. In the case of
`document.addressSpace`, this could reveal some information about network
configuration to third parties. There seems to be no particular reason to treat
third party scripts differently when checking outgoing requests, however.

One area of discussion is
whether or not to treat sandboxed iframes as `public`: see #26. It seems a good
idea to do so, enabling web developers to include third-party content on
non-public websites without allowing it to poke at non-public resources. On the
other hand, this might help malicious websites trying to determine which IP
address they are being accessed from by providing them with a baseline against
which to compare their own capabilities.

## 14. How does this specification work in the context of a user agent’s Private Browsing or "incognito" mode?

It works no differently.

## 15. Does this specification have a "Security Considerations" and "Privacy Considerations" section?

Yes.

## 16. Does this specification allow downgrading default security characteristics?

It does not. While the CORS part might be interpreted as doing so, that is only
valid against a baseline of higher security requirements. On the whole, the
specification is only security-positive, and relaxes no security requirements
compared to the status quo.

## 17. What should this questionnaire have asked?

Nothing else I can think of that would be generic enough to warrant inclusion!
