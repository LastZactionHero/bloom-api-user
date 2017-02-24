class AddApiBedTemplateIdToBeds < ActiveRecord::Migration[5.0]
  def change
    add_column :beds, :api_bed_tmpl_id, :integer
    add_column :beds, :api_bed_tmpl_placements, :jsonb, default: {}
    add_column :beds, :api_bed_tmpl_plant_mapping, :jsonb, default: {}
  end
end
