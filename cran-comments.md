## Test environments

* local Windows 11, R 4.5.3
* win-builder (devel)
* GitHub Actions (macOS, windows, ubuntu)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Version 0.3.0

- Fixed issue #101 (incorrect parenthesis in `gsub()` breaking logout URL
  construction; originally reported by @teofiln in PR #102).
- Added `request_extra_params` option to the `_auth0.yml` config file, so
  extra parameters can be forwarded to the authorization endpoint
  (issue #100).
- Custom URL query parameters are now preserved across the authentication
  round-trip (previously they were dropped).
- Added a `remove_callback_params` argument to `shinyAppAuth0()` that strips
  the `code` and `state` parameters from the URL after successful
  authentication (defaults to `TRUE`).

## Reverse dependencies

There are no reverse dependencies on CRAN.
