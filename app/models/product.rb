class Product < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :project
  belongs_to :issue

  validates :project, :product_name, presence: true
  validates :product_name, uniqueness: { case_sensitive: false,
                                         scope: :project_id }
  validates :quantity, numericality: { only_integer: true,
                                       greater_than_or_equal_to: 0 }
  validates :cost,  numericality: { greater_than_or_equal_to: 0 }
  validates :production_date, :date => true
  validate :validate_product

  safe_attributes 'product_name', 'cost', 'quantity', 'production_date', 'issue_id'

  # Returns a string of css classes that apply to the product
  def css_classes(user=User.current)
    'product'
  end

  def validate_product
    errors.add :project_id, :invalid if project.nil?
    errors.add :issue_id, :invalid if (issue_id && !issue) || (issue && project!=issue.project)
  end

end
