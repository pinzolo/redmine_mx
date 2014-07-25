Rails.application.routes.draw do
  # Global
  namespace :mx, module: nil do
    resources :dbms_products, controller: :mx_dbms_products do
      resources :data_types, controller: :mx_data_types
    end
  end

  # Project local
  resources :projects do
    get :mx, controller: :mx_databases, action: :index

    namespace :mx, module: nil do
      resources :databases, controller: :mx_databases do
        resources :tables, controller: :mx_tables do
          resources :versions, controller: :mx_table_versions, only: [:index, :show]
        end
        resources :common_column_sets, controller: :mx_common_column_sets
      end
    end
  end
end
