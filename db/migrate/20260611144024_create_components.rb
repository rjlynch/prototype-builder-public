class CreateComponents < ActiveRecord::Migration[8.1]
  def change
    create_table :components do |t|
      t.references :page, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :kind, null: false
      t.text :text
      t.string :name
      t.string :label
      t.string :hint

      t.timestamps
      t.index %i[ page_id position ], unique: true
    end
  end
end
