class AddOptionsToComponents < ActiveRecord::Migration[8.1]
  def change
    add_column :components, :options, :text
  end
end
