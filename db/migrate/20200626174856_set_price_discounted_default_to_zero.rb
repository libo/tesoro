class SetPriceDiscountedDefaultToZero < ActiveRecord::Migration[4.2]
  def change
    change_column_default :events, :price_discounted, 0
  end
end
