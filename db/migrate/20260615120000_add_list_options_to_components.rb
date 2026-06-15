class AddListOptionsToComponents < ActiveRecord::Migration[8.1]
  def change
    add_column :components, :list_style, :string, null: false, default: "none"
    add_column :components, :list_spaced, :boolean, null: false, default: false
  end
end
