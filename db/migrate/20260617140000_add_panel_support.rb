class AddPanelSupport < ActiveRecord::Migration[8.1]
  def change
    add_column :pages, :panel_style, :string, null: false, default: "none"
    add_column :components, :in_panel, :boolean, null: false, default: false
  end
end
