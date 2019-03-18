class CreateEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :events do |t|
      t.integer :action, default: 0

      t.references :user
      t.references :currency
      t.references :stock

      t.integer :quantity
      t.decimal :price, precision: 8, scale: 2
      t.decimal :commission, precision: 8, scale: 2
      t.date :executed_on
      t.timestamps
    end
  end
end
