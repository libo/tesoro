class SetScaleTo4ForConversion < ActiveRecord::Migration
  def change
    change_column :conversions, :rate, :decimal, precision: 8, scale: 4
  end
end
