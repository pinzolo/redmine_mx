# redmine_mx

redmine_mx is a plugin for Redmine that manage table definitions.

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
$ bundle exec rake redmine:plugins NAME=redmine_mx
```

### 4. Restart your Redmine

```sh
# In case of using passenger
$ touch tmp/restart.txt
```

## Contributing

1. Fork it ([https://github.com/pinzolo/redmine_mx/fork](https://github.com/pinzolo/redmine_mx/fork))
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
