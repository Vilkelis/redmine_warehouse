class ProductQuery < Query
  self.queried_class = Product
  self.view_permission = :view_products

  def available_columns
    return @available_columns if @available_columns
    @available_columns = [
        QueryColumn.new(:id,
                        :sortable => "#{Product.table_name}.id",
                        :default_order => 'desc',
                        :caption => '#',
                        :frozen => true),
        QueryColumn.new(:product_name,
                        :sortable => "#{Product.table_name}.product_name" ),
        QueryColumn.new(:cost,
                        :sortable => "#{Product.table_name}.cost"),
        QueryColumn.new(:quantity,
                        :sortable => "#{Product.table_name}.quantity",
                        :totalable => true ),
        QueryColumn.new(:production_date,
                        :sortable => "#{Product.table_name}.production_date"),
        QueryColumn.new(:issue,
                        :sortable => "#{Issue.table_name}.name")
    ]
  end

  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= { 'product_name' => {:operator => '*', :values => ['']} }
  end

  def initialize_available_filters
    add_available_filter 'production_date', type: :date, label: :field_production_date
    add_available_filter 'product_name', type: :string, label: :field_product_name
    add_available_filter 'cost', type: :float, label: :field_cost
    add_available_filter 'quantity', type: :integer, label: :field_quantity
    add_available_filter 'issue_id', type: :integer, label: :field_issue
  end

  def base_scope
    Product.joins(:project).left_joins(:issue).where(statement)
  end

  # Returns scope for quering products according options
  # Valid options are :order, :offset, :limit, :include, :conditions
  def option_scope(options={})
    order_option = [group_by_sort_order, (options[:order] || sort_clause)].flatten.reject(&:blank?)
    # The default order of ProductQuery is products.id DESC(by ProductQuery#default_sort_criteria)
    unless ["#{Product.table_name}.id ASC", "#{Product.table_name}.id DESC"].any?{|i| order_option.include?(i)}
      order_option << "#{Product.table_name}.id DESC"
    end

    scope = base_scope.
      includes(([:issue] + (options[:include] || [])).uniq).
      where(options[:conditions]).
      order(order_option).
      joins(joins_for_order_statement(order_option.join(','))).
      limit(options[:limit]).
      offset(options[:offset])

  end

  # Returns the product count
  def product_count
    base_scope.count
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  # Returns the product ids
  # Valid options are :order, :offset, :limit, :include, :conditions
  def product_ids(options={})
    option_scope(options).pluck(:id)
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  # Returns products
  # Valid options are :order, :offset, :limit, :include, :conditions
  def products(options={})
    option_scope(options).to_a
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  def default_columns_names
    @default_columns_names ||= [:product_name, :cost, :quantity, :production_date]
  end

  def default_sort_criteria
    [['id', 'desc']]
  end

  # Returns sum of all the product's quantity
  def total_for_quantity(scope)
    map_total(scope.sum(:quantity)) {|t| t.to_i}
  end
end
