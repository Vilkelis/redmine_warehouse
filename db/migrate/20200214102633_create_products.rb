# Create table for Product store (warehouse)
class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.column :project_id, :integer, :default => 0, :null => false
      t.column :issue_id, :integer
      t.column :name, :string, :default => "", :null => false
      t.column :cost, :float, :default => 0, :null => false
      t.column :quantity, :integer, :default => 0, :null => false
      t.column :production_date, :date
    end
  end
end
