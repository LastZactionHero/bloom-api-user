class CreateBeds < ActiveRecord::Migration[5.0]
  def change
    create_table :beds do |t|
      t.integer :yard_id
      t.string :name
      t.boolean :attached_to_house, default: false
      t.string :orientation
      t.float :width
      t.float :depth
      t.string :sunlight_morning
      t.string :sunlight_afternoon
      t.boolean :watered, default: false

      t.timestamps
    end
    add_index :beds, :yard_id
  end
end
