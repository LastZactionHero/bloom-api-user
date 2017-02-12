class CreateYards < ActiveRecord::Migration[5.0]
  def change
    create_table :yards do |t|
      t.integer :user_id
      t.string :zipcode
      t.string :zone
      t.string :soil
      t.jsonb :preferred_plant_types

      t.timestamps
    end
    add_index :yards, :user_id
    add_index :yards, :zipcode
    add_index :yards, :zone
  end
end
