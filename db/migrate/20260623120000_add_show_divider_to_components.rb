class AddShowDividerToComponents < ActiveRecord::Migration[8.1]
  def change
    add_column :components, :show_divider, :boolean, null: false, default: false
  end
end
