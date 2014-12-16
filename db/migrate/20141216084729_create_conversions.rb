class CreateConversions < ActiveRecord::Migration
  def change
    create_table :conversions do |t|
      t.references :currency
      t.date :book_on
      t.decimal :rate, precision: 8, scale: 2
      t.timestamps
    end
  end
end
