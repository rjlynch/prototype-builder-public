class AddFilePlaybackToComponents < ActiveRecord::Migration[8.1]
  def change
    # The input key whose uploaded file this `file` component plays back, and
    # whether to force a download link instead of rendering an image inline.
    add_column :components, :source_key, :string, null: false, default: ""
    add_column :components, :display_as_link, :boolean, null: false, default: false
  end
end
