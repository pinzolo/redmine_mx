if Redmine::VERSION::STRING < '2.5.0'
  exclude :test_deleted_files_should_not_be_listed, 'not work on current darcs version'
  exclude :test_entries, 'not work on current darcs version'
  exclude :test_entries_invalid_revision, 'not work on current darcs version'
  exclude :test_fetch_changesets_from_scratch, 'not work on current darcs version'
  exclude :test_fetch_changesets_incremental, 'not work on current darcs version'
end
