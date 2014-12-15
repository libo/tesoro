class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.string :name
      t.string :isin
      t.string :symbol
      t.timestamps
    end
  end
end
