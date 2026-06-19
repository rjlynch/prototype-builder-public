class CreateConditions < ActiveRecord::Migration[8.1]
  def up
    create_table :conditions do |t|
      t.references :branch_rule, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :input_name, null: false, default: ""
      t.string :value, null: false, default: ""
      t.timestamps
    end
    add_index :conditions, [ :branch_rule_id, :position ], unique: true

    # Each existing rule held a single inline condition (input_name + value).
    # Move it into its own row so a rule can now hold several conditions,
    # ANDed together.
    execute(<<~SQL)
      INSERT INTO conditions (branch_rule_id, position, input_name, value, created_at, updated_at)
      SELECT id, 1, input_name, value, created_at, updated_at FROM branch_rules
    SQL

    remove_column :branch_rules, :input_name
    remove_column :branch_rules, :value
  end

  def down
    add_column :branch_rules, :input_name, :string, null: false, default: ""
    add_column :branch_rules, :value, :string, null: false, default: ""

    # Collapse each rule's first condition back onto the rule.
    execute(<<~SQL)
      UPDATE branch_rules SET
        input_name = COALESCE((SELECT input_name FROM conditions WHERE conditions.branch_rule_id = branch_rules.id AND conditions.position = 1), ''),
        value = COALESCE((SELECT value FROM conditions WHERE conditions.branch_rule_id = branch_rules.id AND conditions.position = 1), '')
    SQL

    drop_table :conditions
  end
end
