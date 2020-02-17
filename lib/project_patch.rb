# frozen_string_literal: true

require_dependency 'project'

# Add has_many  Products to Project model
module ProjectPatch
  def self.included(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)

    base.class_eval do
      has_many :products, :dependent => :destroy
    end
  end

  module ClassMethods
  end

  module InstanceMethods
  end
end

# Add module to Project
Project.include ProjectPatch
