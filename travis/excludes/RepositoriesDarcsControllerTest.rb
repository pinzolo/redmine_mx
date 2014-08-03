if Redmine::VERSION::STRING < '2.5.0'
  exclude :test_browse_at_given_revision, 'not work on current darcs version'
  exclude :test_browse_directory, 'not work on current darcs version'
  exclude :test_browse_root, 'not work on current darcs version'
  exclude :test_changes, 'not work on current darcs version'
  exclude :test_diff, 'not work on current darcs version'
  exclude :test_destroy_valid_repository, 'not work on current darcs version'
end
