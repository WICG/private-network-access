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

PNA preflight requests are available in Chrome starting in version 98 under warning-mode.
It can be switched between enforcing-mode and warning-mode in following ways:

* the command-line flags: `--enable-features=PrivateNetworkAccessRespectPreflightResults`
* the `chrome://` flag: `chrome://flags/#private-network-access-respect-preflight-results`

Chrome is sending preflight requests ahead of private network requests, but does 
not require the response to be successful. The flag above enables enforcement: 
if the preflight request fails, then the request is not sent.

### Navigations and Workers

PNA preflight requests are also available for navigations and workers under the 
following command-line flags:
* `--enable-features=PrivateNetworkAccessForNavigations`
* `--enable-features=PrivateNetworkAccessForWorkers`
* `--enable-features=PrivateNetworkAccessForNavigationsWarningOnly`
* `--enable-features=PrivateNetworkAccessForWorkersWarningOnly`

The first two flags enable the features under warning-mode. The second two flags
works only when the first two are enabled and enables the enforcement of the 
features.

The second two flags can also be set by the `chrome://` flag:
* `chrome://flags/#private-network-access-ignore-navigation-errors`
* `chrome://flags/#private-network-access-ignore-worker-errors`

### Reducing timeout

In the ideal world, private servers will reply to the preflight requrests no 
matter with or without the correct headers. However, there are several real life 
cases that some servers would just drop the requests they do not understand and 
Chrome will wait forever until a TCP timeout.

In this case, Chrome provides an extra timeout limit, which is 200ms, to limit 
the influence for websites and server haven't yet migrate with Private Network
Access Preflights and do not reply to preflight requests.

This extra timeout limit can be turned off by using the `chrome://` flag 
`chrome://flags/#private-network-access-preflight-short-timeout`.

## Permission Prompt

PNA permission prompt is available in Chrome desktop starting in version 120.

It can be controlled in a variety of ways:
* the command-line flag: `--enable-features=PrivateNetworkAccessPermissionPrompt`
* the `chrome://` flag:
  `chrome://flags/#private-network-access-permission-prompt`
* the [origin
  trial](https://developer.chrome.com/origintrials/#/view_trial/1367968386813788161)

See the [explainer](/permission_prompt/explainer.md) and [walk through doc](https://docs.google.com/document/d/1W70cFFaBGWd0EeOOMxJh9zkmxZ903vKUaGjyF-w7HcY/edit#heading=h.qof2sn5s8r89) for more details.

## Moreover

See [here](https://www.chromium.org/developers/how-tos/run-chromium-with-flags)
for instructions on setting command-line flags.

You can then test your own web app, or use a test page like
https://private-network-access-test.glitch.me/ or 
https://private-network-access-permission-test.glitch.me/ for the permission 
prompt.

Errors should manifest as CORS errors in the DevTools console, and as "Blocked
requests" in the DevTools network panel.
