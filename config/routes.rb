# frozen_string_literal: true

# Plugin's routes
resources :projects, only: [] do
  resources :products, shallow: true do
    member do
      # Used when updating the edit form of an existing product
      patch 'edit', :to => 'products#edit'
    end
  end
end
# Used when updating the new form of an product
post '/projects/:project_id/products/new', :to => 'products#new'
