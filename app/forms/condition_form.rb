# Backs a condition's editor fields (the input and the value it is tested
# against). The target page lives on the owning rule (BranchRuleForm).
class ConditionForm
  include ActiveModel::Model

  def self.model_name
    ActiveModel::Name.new(self, nil, "Condition")
  end

  def self.from_condition(condition)
    new(condition: condition, input_name: condition.input_name, value: condition.value)
  end

  attr_accessor :condition, :input_name, :value

  validates :input_name, :value, length: { maximum: 5_000 }

  def save
    return false unless valid?

    condition.update!(input_name: input_name.to_s, value: value.to_s)
    true
  end
end
