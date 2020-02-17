# frozen_string_literal: true

require_dependency 'queries_controller'

# Add path method to query controller for Products
module QueriesControllerPatch
  def self.included(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)
  end

  module ClassMethods
  end

  module InstanceMethods
    def redirect_to_product_query(options)
      redirect_to project_products_path(@project, options)
    end
  end
end

# Add module to QueryController
QueriesController.include QueriesControllerPatch
