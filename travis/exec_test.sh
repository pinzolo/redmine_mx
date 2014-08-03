#! /bin/sh

export REDMINE_LANG=en
export RAILS_ENV=test
PLUGIN_NAME="redmine_mx"

# Initialize redmine
bundle exec rake generate_secret_token
bundle exec rake db:migrate
#bundle exec rake redmine:load_default_data

# Copy assets & execute plugin's migration
bundle exec rake redmine:plugins NAME=${PLUGIN_NAME}

if [ $TARGET = "redmine" ]; then
  export SCMS=bazaar,cvs,subversion,git,mercurial,filesystem

  # Execute redmine tests
  bundle exec rake ci
else
  # Execute plugin test
  bundle exec rake redmine:plugins:test NAME=${PLUGIN_NAME}
fi

