# frozen_string_literal: true

require_dependency 'issue'

# Add has_many  Products to Issue model
module IssuePatch
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

# Add module to Issue
Issue.include IssuePatch
