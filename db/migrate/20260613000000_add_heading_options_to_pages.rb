class AddHeadingOptionsToPages < ActiveRecord::Migration[8.1]
  def change
    add_column :pages, :heading_size, :string, null: false, default: "l"
    add_column :pages, :caption, :string, null: false, default: ""
  end
end
