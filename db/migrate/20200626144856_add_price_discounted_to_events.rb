class AddPriceDiscountedToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :price_discounted, :decimal, precision: 8, scale: 4
  end
end
