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

DO USE A SOURCE-CODE-MANAGEMENT-SYSTEM (Git). There is no guarantee that programm will not destroy your workspace :)


```
buk-extract-i18n --help

buk-extract-i18n app/controllers/admin
```

If you prefer relative keys in slim views use ``--slim-relative``, e.g. ``t('.title')`` instead of ``t('users.index.title')``.
I prefer absolute keys, as it makes copy pasting/ moving files much safer.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kb714/buk_extract_i18n.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
