class AddSoilToBeds < ActiveRecord::Migration[5.0]
  def change
    add_column :beds, :soil, :string
  end
end
