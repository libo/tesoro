class SetCommissionDefaultToZero < ActiveRecord::Migration
  def change
    change_column_default :events, :commission, 0
  end
end
