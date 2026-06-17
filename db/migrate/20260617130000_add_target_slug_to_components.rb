class AddTargetSlugToComponents < ActiveRecord::Migration[8.1]
  def change
    add_column :components, :target_slug, :string, null: false, default: ""
  end
end
