# auth0 0.1.1

- added user info support with `session$userData`
- added option to set configuration YAML file path in `options(auth0_config_file=)`
- update `use_auth0` function to also use `AUTH0_USER` environment variable to fill the `api_url` parameter automatically in the `_auth0.yml` file.
- minor errors and bug fixes.
