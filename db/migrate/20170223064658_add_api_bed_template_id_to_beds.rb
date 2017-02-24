class AddApiBedTemplateIdToBeds < ActiveRecord::Migration[5.0]
  def change
    add_column :beds, :template_id, :integer
    add_column :beds, :template_placements, :jsonb, default: {}
    add_column :beds, :template_plant_mapping, :jsonb, default: {}
  end
end
