# Explainer: Private Network Access

## Quick links

- [Specification](https://wicg.github.io/private-network-access)
- [Repository](https://github.com/WICG/private-network-access)
- [Issue tracker](https://github.com/WICG/private-network-access/issues)

## Introduction

Private Network Access is a web specification which aims to protect websites
accessed over the private network (either on localhost or a private IP address)
from malicious cross-origin requests.

Say you visit evil.com, we want to prevent it from using your browser as a
springboard to hack your printer. Perhaps surprisingly, evil.com can easily
accomplish that in most browsers today (given a web-accessible printer
exploit).

This specification used to be named "CORS-RFC1918" , after
[CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS), which
provides a mechanism for securing websites against cross-origin requests,
and [RFC 1918](https://tools.ietf.org/html/rfc1918), which describes IPv4
address ranges reserved for private networks.

## Goals

The overarching goal is to prevent malicious websites from pivoting through
the user agent's network position to attack devices and services which
reasonably assumed they were unreachable from the Internet at large, by
virtue of residing on the user’s local intranet or the user's machine.

For example, we wish to mitigate
attacks on:

- Users' routers, as outlined in
  [SOHO Pharming](https://331.cybersec.fun/TeamCymruSOHOPharming.pdf).
  Note that status quo CORS protections don’t protect against the kinds of
  attacks discussed here as they rely only on
  [CORS-safelisted methods](https://fetch.spec.whatwg.org/#cors-safelisted-method)
  and
  [CORS-safelisted request-headers](https://fetch.spec.whatwg.org/#cors-safelisted-request-header).
  No preflight is triggered, and the attacker doesn’t actually care about
  reading the response, as the request itself is the CSRF attack.
- Software running a web interface on a user’s loopback address. For better or
  worse, this is becoming a common deployment mechanism for all manner of
  applications, and often assumes protections that simply don’t exist (see
  [recent](https://code.google.com/p/google-security-research/issues/detail?id=679)
  [examples](https://code.google.com/p/google-security-research/issues/detail?id=693)).

## Non-goals

Provide a secure mechanism for initiating HTTPS connections to services
running on the local network or the user’s machine. This piece is missing to
allow secure public websites to embed non-public resources without running into
mixed content violations, with the exception of `http://localhost` which is
embeddable. While a useful goal, and maybe even a necessary one in order to
deploy Private Network Access more widely, it is out of scope of this
specification.

## Proposed design

### Address spaces

We extend the [RFC 1918](https://tools.ietf.org/html/rfc1918) concept of
private IP addresses to build a model of network privacy. In this model,
there are 3 main layers to an IP network from the point of view of a node,
which we organize from most to least private:

- Localhost - accessible only to the node itself, by default
- Private IP addresses - accessible only to the members of the local network
- Public IP addresses - accessible to anyone

We call these layers **address spaces**: `local`, `private`, and `public`.

The mapping from IP address to address space is defined [in the specification](
https://wicg.github.io/private-network-access/#ip-address-space), and may be
overridden by user agents through user or administrator configuration.

It might also be useful to consider web origins when determining address spaces.
For example, the `.local.` top-level DNS domain (see
[RFC 6762](https://tools.ietf.org/html/rfc6762)) might be always be considered
`private`. See this
[discussion](https://github.com/WICG/private-network-access/issues/4).

#### Proxies

Proxies influence the address space of resources they proxy. If `foo.example`,
served on a public IP address, is accessed by a browser via a proxy on a private
IP address (e.g. `192.168.1.123`), then the resource will be considered to have
been fetched from a private IP address. The resource will in turn be allowed to
make requests to other private IP addresses accessible to the browser. This can
allow `foo.example` to learn that it was proxied by observing that it is allowed
to make requests to [=private addresses=], which is a privacy information leak.
Note however that this requires correctly guessing the URL of a resource on the
private network. On the other hand a single correct guess is enough.

This is expected to be relatively rare and not warrant more mitigations. After
all, in the status quo all websites can make requests to all IP addresses with
no restrictions whatsoever.

It would be interesting to explore a mechanism by which proxies could tell the
browser "please treat this resource as public/private anyway", thereby passing
on some information about the IP address behing the proxy. This might take the
form of the CSP directive discussed below, with some minor modifications.

### Private network requests

The address space concept and accompanying model of IP address privacy lets us
define the class of requests we wish to secure.

We define a **private network request** as a request crossing an address space
boundary to a more-private address space.

Concretely, there are 3 kinds of private network requests:

1. `public` -> `private`
2. `public` -> `local`
3. `private` -> `local`

Note that `private` -> `private` is not a private network request, as well as
`local` -> anything.

### Integration with Fetch

Private network requests are handled differently than others, like so:

- If the client is not in a
  [secure context](https://www.w3.org/TR/secure-contexts/), the request is
  blocked. 
- Otherwise, the original request is preceded by a
  [CORS pre-flight request](https://fetch.spec.whatwg.org/#cors-preflight-request).
  - There are no exceptions for CORS safelisting.
  - The pre-flight request carries an additional
    `Access-Control-Request-Private-Network: true` header.
  - The response must carry an additional
    `Access-Control-Allow-Private-Network: true` header.

The Fetch spec does not yet integrate the details of DNS resolution,
only defining an **obtain a connection** algorithm, thus Private Network Access
checks are applied to the newly-obtained connection. Given complexities such as
Happy Eyeballs ([RFC6555](https://datatracker.ietf.org/doc/html/rfc6555),
[RFC8305](https://datatracker.ietf.org/doc/html/rfc8305), these checks might
pass or fail non-deterministically for hosts with multiple IP addresses that
straddle IP address space boundaries.

### Integration with HTML

`Document`s and `WorkerGlobalScope`s store an additional **address space**
value. This is initialized from the IP address the document or worker was
sourced from.

A new directive is introduced to
[CSP](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP):
`treat-as-public-address`. If a document or worker's CSP list includes this
directive, then its address space is set to `public` unconditionally.

A previous version of this specification introduced a new `addressSpace`
attribute to `Document` and `WorkerGlobalScope` to allow for introspection from
Javascript. This was removed over security and privacy concerns, see #21.

### Integration with WebSockets

The initial handshake for private network requests is modified like so:

- The handshake request carries an additional
  `Access-Control-Request-Private-Network: true` header.
- The response must carry an additional
  `Access-Control-Allow-Private-Network` header.

## Alternatives considered

### Cover all cross-origin requests targeting the local network

Define **private network request** instead as: any request targeting an IP
address in the local or private address spaces, regardless of the requestor’s
address space.

This definition is strictly broader than the one we are currently working
with. It seems likely to cause more widespread breakage in the web ecosystem.
We would like to first launch the current version and consider this instead
as an interesting avenue for future work.
