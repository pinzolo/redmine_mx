Rails.application.routes.draw do
  # Global
  namespace :mx, module: nil do
    resources :dbms_products, controller: :mx_dbms_products
  end

  # Project local
  resources :projects do
    get :mx, controller: :mx_databases, action: :index

    namespace :mx, module: nil do
      resources :databases, controller: :mx_databases do
        resources :tables, controller: :mx_tables do
          get :columns, on: :member
          resources :versions, controller: :mx_table_versions, only: [:index]
          match 'versions/:version', to: 'mx_table_versions#show', via: :get, as: 'version'
        end
        resources :column_sets, controller: :mx_column_sets
      end
    end
  end
end
