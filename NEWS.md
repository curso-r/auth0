# auth0 0.1.2

- (breaking change) change `login_info` to `auth0_info` in the user session data (Issue #19).
- Option to ignore auth0 and work as a normal shiny app, to save developing time (Issue #26).
- Examples for different login types (google/facebook, database etc, Issue #23).
- Solve bookmarking and URL parameters issue (Issue #22).
- Improved logout button (Issue #24) (thanks to Dean Attali)
- Improve handling and documentation of the config_file option (Issue #25).
- Use `auth0App()` instead of `shinyAuth0App()` and soft-deprecate `shinyAuth0App()` (Issue #18).
- Better documentation
      - Handle multiple shiny apps and multiple auth0 apps (Issue #17).
      - Explain some RStudio details(Issues #15 and #16).
      - Explain environment variables (Issue #14).
      - Explain yml file config (Issue #13).
- Add Dean Attali as contributor to the package.
- test whitelisting with auth0 (Issue #10)

# auth0 0.1.1

- added user info support with `session$userData`
- added option to set configuration YAML file path in `options(auth0_config_file=)`
- update `use_auth0` function to also use `AUTH0_USER` environment variable to fill the `api_url` parameter automatically in the `_auth0.yml` file.
- minor errors and bug fixes.
