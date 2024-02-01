# Private Network Access Permission to relax mixed content for non-fetch requests

- **Author**: lyf@google.com
- **Created**: 2023-11-24
- **Last Updated**: 2024-01-26

## Problem

Currently, any public page can make a request as if they were the user's machine. This allows a malicious attacker to use a public web page to attack network endpoints on a user's private network. These endpoints (router, printer, IoT devices, ...) are often badly protected because they do not expect to receive requests from the web at large.

To mitigate this threat, we have been working on the Private Network Access (PNA) spec, which prevents public pages from making requests to private network endpoints, unless the endpoint opts into receiving the request from the public origin. This model works if the origin can be validated, i.e. if the public page is served over HTTPS. To support PNA, we want to remove the ability for public HTTP pages to make requests on private network endpoints.

This means that public pages served on HTTP that embed resources from the private network need to upgrade to HTTPS. However, there is currently no good solution for encryption on the private network, meaning that many of those subresources are served over HTTP and cannot upgrade to HTTPS. They cannot be embedded in an HTTPS page due to mixed contents checks.

To solve this issue, we have introduced a permission prompt to relax mixed contents checks when fetching resources from the private network. For more details, please check [Private Network Access Permission to relax mixed content](/explainer.md).

While the above solution effectively addresses fetch requests, it doesn't handle iframes or HTML src attributes due to the requirement of manual `targetAddressSpace` setting in fetch options. To provide a comprehensive solution, we need a mechanism that extends this control to non-fetch requests as well.

> Notes: Top-level navigation is exempt from permission prompts as it doesn't trigger mixed content warnings.

## Deprecated solutions
### Service worker

In the [previous discussion](https://github.com/WICG/private-network-access/issues/83), we planned to introduce the permission for
workers, so that it can be used for non-fetch requests. However, the mixed 
content check actually happens before service workers, which means it won't work.

## Solution

In this case, we would like to introduce a new [Content Security Policy](https://www.w3.org/TR/CSP3/) to let 
all documents declare their IP address space.

### New [directive](https://www.w3.org/TR/CSP3/#framework-directives)

Two new Content Security Policy directives are introduced for Private Network Access, 
`private-address-space` and `local-address-space`.

> Notes: `localhost`, `::1/128` and `127.0.0.1` hosts are regard as secure in mixed 
> content check, so that we don't need to relax. Benchmarking address 198.18.0.0/15 is regarded as a local IP address in Private Network Access specification but not potentially trustworthy origin in secure contexts spec.

### Policy delivery

[The same as all the other Content Security Policies](https://www.w3.org/TR/CSP3/#policy-delivery), private/local IP address 
space can be declared as either a HTTP header or a HTML `<meta>` element.

#### HTTP header

To declare one or more private IP addresses:

```text
Content-Security-Policy: private-address-space <private_host>
Content-Security-Policy: private-address-space <private_host> <private_host>
```

Example:
```text
Content-Security-Policy: private-address-space example.com *.example.com
```

To declare one or more local IP addresses:

```text
Content-Security-Policy: local-address-space <local_host>
Content-Security-Policy: local-address-space <local_host> <local_host>
```

Example:
```text
Content-Security-Policy: local-address-space localhost
```

#### <meta> element

```text
<meta http-equiv="Content-Security-Policy" content="private-address-space example.com; local-address-space localhost">
```

### Reporting

The same as all the other Content Security Policies, report-to directive is 
available for private/local IP addresses when the CSP is not valid, for example, unrecognized keyword, invalid URL, etc.

Whether a certain URL is pointing to local/private IP addresses won’t be recorded or reported because of privacy issues.

### [Content-Security-Policy-Report-Only](https://www.w3.org/TR/CSP3/#cspro-header)

Same as above, the report only mode would only report invalid CSPs but not whether the IP address space is correct or not.

## Furthermore

This new CSP can be used not only for navigations but also for a variety of use
cases. Examples include HTML image tags and even as an alternative to fetch
requests. If the target address space is already defined in the Content
Security Policy, the targetAddressSpace fetch option will no longer be
necessary."
