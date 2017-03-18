class CreatePromoCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :promo_codes do |t|
      t.string :code
      t.float :discount, default: 0.0
      t.boolean :reusable, default: true
      t.integer :use_count, default: 0
      t.datetime :expiration

      t.timestamps
    end
    add_index :promo_codes, :code
  end
end
