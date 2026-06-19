# Secure Custom Fields stubs

[PHPStan](https://phpstan.org/) / static-analysis stubs for the [**Secure Custom Fields**](https://wordpress.org/plugins/secure-custom-fields/) WordPress plugin — the WordPress.org-maintained, ACF-compatible custom-fields plugin.

Use these when your plugin/theme calls Secure Custom Fields (or ACF-compatible) functions like `get_field()`, `the_field()`, `acf_*()`, `have_rows()`, etc., so PHPStan knows their signatures instead of reporting "undefined function".

## Install

```bash
composer require --dev mralaminahamed/secure-custom-fields-stubs
```

Pin to a plugin version if you want stubs matching a specific release:

```bash
composer require --dev mralaminahamed/secure-custom-fields-stubs:6.8.9
```

## Use with PHPStan

Reference the stub files in your `phpstan.neon`:

```neon
parameters:
    scanFiles:
        - vendor/mralaminahamed/secure-custom-fields-stubs/secure-custom-fields-stubs.stub
        - vendor/mralaminahamed/secure-custom-fields-stubs/secure-custom-fields-constants-stubs.stub
```

## Versioning

Releases are tagged `v<plugin-version>` (e.g. `v6.8.9`) and track the upstream Secure Custom Fields releases. Each tag's stubs are generated from that exact plugin version.

## Regenerate locally

```bash
composer install
bash bin/release-latest-versions.sh 5   # latest 5 stable versions
# or, against a source/ you placed manually:
bash bin/generate.sh
```

## License

MIT. Stub declarations are generated from the GPL-licensed Secure Custom Fields plugin source using [php-stubs/generator](https://github.com/php-stubs/generator).
