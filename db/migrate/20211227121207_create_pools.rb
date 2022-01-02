class CreatePools < ActiveRecord::Migration[6.1]
  def change
    create_table :pools do |t|
      t.references :event, index: { unique: true }

      t.decimal :value, precision: 8, scale: 2, default: 0
      t.integer :size, default: 0
    end
  end
end
