# redmine_mx
[![Build Status](https://secure.travis-ci.org/pinzolo/redmine_mx.png)](http://travis-ci.org/pinzolo/redmine_mx)
[![Coverage Status](https://coveralls.io/repos/pinzolo/redmine_mx/badge.png)](https://coveralls.io/r/pinzolo/redmine_mx)

redmine_mx is a Redmine's plugin for management table definitions.

## Installation

Execute follow commands at your Redmine directory.

### 1. Clone to your Redmine's plugins directory:

```sh
$ git clone https://github.com/pinzolo/redmine_mx.git plugins/redmine_mx
```

### 2. Install dependency gems:

```sh
$ bundle install --without test development
```

### 3. Execute migration and deploy assets:

```sh
$ bundle exec rake redmine:plugins NAME=redmine_mx RAILS_ENV=production
```

### 4. Restart your Redmine

```sh
# In case of using passenger
$ touch tmp/restart.txt
```

## Supported versions

- Ruby: 1.9.3, 2.0.0, 2.1.x
- Redmine: 2.3.x, 2.4.x, 2.5.x

This plugin does not work in IE8 and below, because redmine_mx uses [Vue.js](http://vuejs.org/).

## Contributing

1. Fork it ([https://github.com/pinzolo/redmine_mx/fork](https://github.com/pinzolo/redmine_mx/fork))
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
