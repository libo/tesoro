class CreateCurrencies < ActiveRecord::Migration[4.2]
  def change
    create_table :currencies do |t|
      t.string :name
      t.string :code
      t.string :locale
      t.decimal :default_conversion_rate, precision: 8, scale: 2
      t.timestamps
    end
  end
end
