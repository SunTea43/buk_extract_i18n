# BukExtractI18n

Project and original idea: https://github.com/pludoni/extract_i18n

Project made exclusively for the extraction of texts on the BUK platform.

CLI helper program to automatically extract bare text strings into Rails I18n interactively.

Useful when adding i18n to a medium/large Rails app.

This Gem **supports** the following source files:

- Ruby files (controllers, models etc.) via Ruby-Parser, e.g. walking all Ruby Strings
- ERB views
  - WIP
## Installation

install Gemfile:

    gem 'buk_extract_i18n', git: 'https://github.com/kb714/buk_extract_i18n', branch: :main

## Usage

```
buk-extract-i18n --help

buk-extract-i18n app/controllers/admin
```

If you prefer relative keys in slim views use ``--slim-relative``, e.g. ``t('.title')`` instead of ``t('users.index.title')``.
I prefer absolute keys, as it makes copy pasting/moving files much safer.

By default, the path of the generated YMLs share the same path as the file from which they are extracted, the name is given by the language you are working with.

For example:

If you extract the text from
```
app/cells/employee/form/show.erb
```
The YML it generates will be in
```
config/locales/cells/employee/form/show/es.yml
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
