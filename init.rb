Redmine::Plugin.register :redmine_mx do
  name 'Redmine MX'
  author 'pinzolo'
  description 'redmine_mx is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/pinzolo/redmine_mx'
  author_url 'https://github.com/pinzolo'

  project_module :mx do
    permission :view_mx_tables, mx_tables: [:index, :show],
                                mx_table_lists: [:index, :show],
                                mx_common_column_sets: [:show],
                                mx_table_versions: [:index, :show]
    permission :manage_mx_tables, mx_tables: [:new, :edit, :create, :update, :destroy],
                                  mx_table_lists: [:new, :edit, :create, :update, :destroy],
                                  mx_common_column_sets: [:new, :edit, :create, :update, :destroy],
                                  require: :member
  end

  menu :project_menu, :mx, { controller: :mx_table_lists, action: :index }, param: :project_id, caption: :'mx.label_mx'
  menu :admin_menu, :mx_database, { controller: :mx_databases, action: :index }, caption: :'mx.label_mx_databases'
end
