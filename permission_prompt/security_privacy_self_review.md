# Security and Privacy Self-Review: Private Network Access Permission Prompt

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

See [#41](https://github.com/WICG/private-network-access/issues/41) for a
discussion of these points.

## 2. Do features in your specification expose the minimum amount of information necessary to enable their intended uses? 

Yes, apart from the above.

## 3. How do the features in your specification deal with personal information, personally-identifiable information (PII), or information derived from them?

It does not.

## 4. How do the features in your specification deal with sensitive information?

It does not.

## 5. Do the features in your specification introduce new state for an origin that persists across browsing sessions?

Yes, the permission status which allows a certain public webpage to access a
certain private/local service.

## 6. Do the features in your specification expose information about the underlying platform to origins?

See question 1.

## 7. Does this specification allow an origin to send data to the underlying platform?

No.

## 8. Do features in this specification enable access to device sensors?

No.

## 9. Do features in this specification enable new script execution/loading mechanisms?

No.

## 10. Do features in this specification allow an origin to access other devices?

Compared to the previous version of Private Network Access, this feature relaxes
mixed content check and allows access to devices via plaintext.

However, compared to the current state of the web, it restricts the capabilities
to secure contexts and introduces a new hurdle, the permission prompt.

## 11. Do features in this specification allow an origin some measure of control over a user agent’s native UI?

No.

## 12. What temporary identifiers do the features in this specification create or expose to the web?

None.

## 13. How does this specification distinguish between behavior in first-party and third-party contexts?

The permission can only be granted to the top-level page.

We might want to relax the boundary and also allow same-origin child contexts to
be able to request the permission by default. However, third-party contexts (e.g. iframes) would
not be allowed.

In the future, it might make sense to allow top-level documents to control its
permission with permission policy and even allow the private network access
permission to be delegated to third-party contexts. In that case, third-party
context should be the one taking into account for the permission.

## 14. How do the features in this specification work in the context of a browser’s Private Browsing or Incognito mode?

The permission gained from the users would be cached only for the duration of the
incognito session, and the incognito session won’t inherit the cached permissions
in the normal mode.

## 15. Does this specification have both "Security Considerations" and "Privacy Considerations" sections?

Yes.

## 16. Do features in your specification enable origins to downgrade default security protections?

No.

## 17. How does your feature handle non-"fully active" documents?

Access will be prohibited.

## 18. What should this questionnaire have asked?

Nothing else I can think of.
