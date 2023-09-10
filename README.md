# ExtractI18n

Project and original idea: https://github.com/pludoni/extract_i18n

Project made exclusively for the extraction of texts on the BUK platform.

CLI helper program to automatically extract bare text strings into Rails I18n interactively.

Useful when adding i18n to a medium/large Rails app.

This Gem **supports** the following source files:

- Ruby files (controllers, models etc.) via Ruby-Parser, e.g. walking all Ruby Strings
- ERB views
  - by vendoring/extending https://github.com/ProGM/i18n-html_extractor (MIT License)

I strongly recommend using a Source-Code-Management (Git) and ``i18n-tasks`` for checking the key consistency.
I've created a scanner to make that work with vue $t structures too: https://gist.github.com/zealot128/e6ec1767a40a6c3d85d7f171f4d88293

## Installation

install:

    $ gem install extract_i18n

## Usage

DO USE A SOURCE-CODE-MANAGEMENT-SYSTEM (Git). There is no guarantee that programm will not destroy your workspace :)


```
extract-i18n --help

extract-i18n app/controllers/admin
```

If you prefer relative keys in slim views use ``--slim-relative``, e.g. ``t('.title')`` instead of ``t('users.index.title')``.
I prefer absolute keys, as it makes copy pasting/ moving files much safer.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kb714/extract_i18n.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
