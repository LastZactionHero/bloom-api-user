class ChangeBedSunlightToBoolean < ActiveRecord::Migration[5.0]
  def up
    remove_column :beds, :sunlight_morning
    remove_column :beds, :sunlight_afternoon

    add_column :beds, :sunlight_morning, :boolean, default: false
    add_column :beds, :sunlight_afternoon, :boolean, default: false
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
