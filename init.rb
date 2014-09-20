Redmine::Plugin.register :redmine_mx do
  name 'Redmine MX'
  author 'pinzolo'
  description "redmine_mx is a Redmine's plugin for management table definitions"
  version '0.0.1'
  url 'https://github.com/pinzolo/redmine_mx'
  author_url 'https://github.com/pinzolo'

  project_module :mx do
    permission :view_mx_tables, mx_tables: [:index, :show, :columns],
                                mx_databases: [:index, :show],
                                mx_column_sets: [:index, :show],
                                mx_table_versions: [:index, :show]
    permission :manage_mx_tables, mx_tables: [:new, :edit, :create, :update, :destroy],
                                  mx_databases: [:new, :edit, :create, :update, :destroy],
                                  mx_column_sets: [:new, :edit, :create, :update, :destroy],
                                  require: :member
  end

  menu :project_menu, :mx, { controller: :mx_databases, action: :index }, param: :project_id, caption: :'mx.label_mx'
  menu :admin_menu, :mx_dbms_products, { controller: :mx_dbms_products, action: :index }, caption: :'mx.label_dbms_products'
end

Dir.glob(File.join(File.dirname(__FILE__), 'app/*')) do |dir|
  next if ActiveSupport::Dependencies.autoload_paths.include?(dir) || File.basename(dir) == 'views'
  ActiveSupport::Dependencies.autoload_paths << dir
end

