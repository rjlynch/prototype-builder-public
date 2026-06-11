class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages do |t|
      t.references :wizard, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :title, null: false, default: ""

      t.timestamps
      t.index %i[ wizard_id position ], unique: true
    end
  end
end
