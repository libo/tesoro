class ChangeEventPricePrecision < ActiveRecord::Migration
  def change
    change_column :events, :price, :decimal, precision: 8, scale: 4
    change_column :events, :commission, :decimal, precision: 8, scale: 4
  end
end
