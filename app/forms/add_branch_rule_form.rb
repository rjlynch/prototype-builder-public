# Appends a blank branch rule to a button, ready to be filled in.
class AddBranchRuleForm
  include ActiveModel::Model

  attr_accessor :component
  attr_reader :branch_rule

  validates :component, presence: true
  validate :component_is_a_button

  def save
    return false unless valid?

    position = (component.branch_rules.maximum(:position) || 0) + 1
    @branch_rule = component.branch_rules.create!(position: position)
    true
  end

  private

  def component_is_a_button
    errors.add(:component, "must be a button") unless component&.kind == "button"
  end
end
