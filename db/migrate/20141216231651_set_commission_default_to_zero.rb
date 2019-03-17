class SetCommissionDefaultToZero < ActiveRecord::Migration[4.2]
  def change
    change_column_default :events, :commission, 0
  end
end
