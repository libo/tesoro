class AddSortColumnToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :sort_column, :string

    add_index :events, :sort_column, unique: true
  end
end
