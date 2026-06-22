class AddSummaryKeysToComponents < ActiveRecord::Migration[8.1]
  def change
    # The input keys a `check_answers` summary list plays back, one per line.
    # Its own column rather than reusing `text`, matching the table's other
    # per-kind config columns (options, source_key, list_style).
    add_column :components, :summary_keys, :text, null: false, default: ""
  end
end
