class AddButtonStyleToComponents < ActiveRecord::Migration[8.1]
  def change
    add_column :components, :button_style, :string, null: false, default: "continue"
  end
end
