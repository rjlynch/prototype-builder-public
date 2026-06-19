class AddInlineToComponents < ActiveRecord::Migration[8.1]
  def change
    add_column :components, :inline, :boolean, null: false, default: false
  end
end
