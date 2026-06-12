class AddTitleAsLabelToComponents < ActiveRecord::Migration[8.1]
  def change
    add_column :components, :title_as_label, :boolean, null: false, default: false
  end
end
