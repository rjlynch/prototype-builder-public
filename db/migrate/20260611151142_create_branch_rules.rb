class CreateBranchRules < ActiveRecord::Migration[8.1]
  def change
    create_table :branch_rules do |t|
      t.references :component, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :input_name, null: false, default: ""
      t.string :value, null: false, default: ""
      t.string :target_slug, null: false, default: ""

      t.timestamps
      t.index %i[ component_id position ], unique: true
    end
  end
end
