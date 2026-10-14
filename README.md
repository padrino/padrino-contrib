# padrino-contrib

## Contributed Plugins and Utilities

This package includes a variety of add-on components for Padrino Framework:

* breadcrumbs               - Simple breadcrumb navigation helpers
* exception_notifier        - Send errors through mail or/and to redmine
* auto_locale               - Switch for you automatically the I18n.locale
* orm_ar_permalink          - Generate permalink for a specified column on ActiveRecord
* orm_ar_permalink_i18n     - Generate permalink for a specified multi language column(s) on ActiveRecord
* orm_ar_translate          - Translate for you your ActiveRecord columns

## Use

In your Padrino project edit:

```ruby
# Gemfile
gem 'padrino-contrib'

# boot.rb
require 'padrino-contrib/exception_notifier'
# require 'padrino-contrib/orm/active_record/permalink'
# require 'padrino-contrib/orm/active_record/textile'
# require 'padrino-contrib/helpers/breadcrumbs'

Padrino.load! # Remember to add contribs before that line!

# app.rb
class MyApp < Padrino::Application
  register Padrino::Contrib::ExceptionNotifier
end
```

The exception notifier hides any param or env key that contains one of the words in
`exceptions_params_filter`, ignoring case, or matches a Regexp in it. The default is
`['passw', 'secret', 'token', '_key', 'apikey', 'crypt']`, so `passw` also covers
`password_confirmation` and `_key` covers `api_key`; setting the option replaces the
list. The exception message is reported as it is, so keep request data out of it.

## Removed modules

These modules depended on software that is no longer maintained, or duplicated
what Padrino now ships, and have been removed:

* `Padrino::Contrib::Helpers::AssetsCompressor` (`helpers/assets_compressor`): relied on
  `alias_method_chain` and the YUI compressor. Use an asset pipeline instead.
* `Padrino::Contrib::Helpers::JQuery` (`helpers/jquery`): downloaded jQuery 1.7 over plain HTTP.
  Vendor the script and use `javascript_include_tag`.
* `Padrino::Contrib::FlashSession` (`flash_session`): passed the session in the URL for Adobe
  Flash uploaders, which browsers no longer run.
* `Padrino::Contrib::Helpers::Flash` (`helpers/flash`): Padrino registers its own `flash`
  (`Padrino::Flash`) in every application.
* `orm/mongo_mapper/permalink` and `orm/mongo_mapper/search`: MongoMapper is no longer maintained.
