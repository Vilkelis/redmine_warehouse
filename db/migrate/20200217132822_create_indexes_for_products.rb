
# Add some usefull indexes to the Products table
class CreateIndexesForProducts < ActiveRecord::Migration[5.2]
  def change
    add_index :products, [:issue_id]
    add_index :products, [:project_id]
    add_index :products, [:product_name]
  end
end
