# redmine_mx

redmine_mx is a plugin for Redmine.

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
