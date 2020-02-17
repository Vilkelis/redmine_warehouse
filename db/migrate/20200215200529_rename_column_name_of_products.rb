# Rename Name field to "Product name" of Products table
class RenameColumnNameOfProducts < ActiveRecord::Migration[5.2]
  def change
    rename_column :products, :name, :product_name
  end
end
