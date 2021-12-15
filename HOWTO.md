# How to experiment with Private Network Access

## Secure context restriction

The secure context restriction is enabled by default for subresources embedded
by public websites in Chrome starting in version 94. See the
[blog post](https://developer.chrome.com/blog/private-network-access-update/)
for more details.

It can be controlled in a variety of ways:

* the command-line flag: `--enable-features=BlockInsecurePrivateNetworkRequests`
* the `chrome://` flag:
  `chrome://flags/#block-insecure-private-network-requests`
* the [deprecation
  trial](https://developer.chrome.com/origintrials/#/view_trial/4081387162304512001)
* the enterprise policies:
  [InsecurePrivateNetworkRequestsAllowed](https://chromeenterprise.google/policies/#InsecurePrivateNetworkRequestsAllowed)
  and
  [InsecurePrivateNetworkRequestsAllowedForUrls](https://chromeenterprise.google/policies/#InsecurePrivateNetworkRequestsAllowedForUrls)

## Preflight requests

PNA preflight requests are available in Chrome starting in version 98 behind
a pair of command-line flags:

1. `--enable-features=PrivateNetworkAccessSendPreflights`
2. `--enable-features=PrivateNetworkAccessRespectPreflightResults`

The former configures Chrome to send preflight requests ahead of private network
requests, but not does require the response to be successful. The latter enables
enforcement: if the preflight request fails, then the request is not sent.

See [here](https://www.chromium.org/developers/how-tos/run-chromium-with-flags)
for instructions on setting command-line flags.

You can then test your own web app, or use a test page like
https://private-network-access-test.glitch.me/.

Errors should manifest as CORS errors in the DevTools console, and as "Blocked
requests" in the DevTools network panel.
