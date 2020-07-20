class AddIncludeDiscountToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :include_discount, :boolean, default: false
  end
end
