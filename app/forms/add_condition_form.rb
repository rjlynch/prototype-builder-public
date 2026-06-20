# Appends a blank condition to a branch rule, ready to be filled in. The new
# condition ANDs with the rule's existing ones.
class AddConditionForm
  include ActiveModel::Model

  attr_accessor :branch_rule
  attr_reader :condition

  validates :branch_rule, presence: true

  def save
    return false unless valid?

    position = (branch_rule.conditions.maximum(:position) || 0) + 1
    @condition = branch_rule.conditions.create!(position: position)
    true
  end
end
