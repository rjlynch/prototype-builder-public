class AddSlugToPages < ActiveRecord::Migration[8.1]
  def change
    add_column :pages, :slug, :string

    reversible do |direction|
      direction.up { execute "UPDATE pages SET slug = 'page-' || position" }
    end

    change_column_null :pages, :slug, false
    add_index :pages, %i[ wizard_id slug ], unique: true
  end
end
