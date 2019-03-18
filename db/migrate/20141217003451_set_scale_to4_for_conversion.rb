class SetScaleTo4ForConversion < ActiveRecord::Migration[4.2]
  def change
    change_column :conversions, :rate, :decimal, precision: 8, scale: 4
  end
end
