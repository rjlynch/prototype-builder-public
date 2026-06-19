# One "answer X is Y" test within a branch rule. A rule's conditions are
# ANDed, so every complete condition must match for the rule to fire.
# Conditions are filled in gradually via autosubmit, so blanks are allowed;
# only complete conditions take part in matching.
class Condition < ApplicationRecord
  belongs_to :branch_rule

  validates :position,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :branch_rule_id }
  validates :input_name, :value, length: { maximum: 5_000 }

  def complete?
    [ input_name, value ].all?(&:present?)
  end

  # Values are compared parameterised so "Yes" matches "yes" — kinder to
  # non-technical builders than exact string matching. The answer is treated
  # as a set: a checkbox group supplies several values and the condition
  # matches when its value is among them; a text or radio answer is a set of
  # one, so membership there is plain equality.
  def matches?(answers)
    complete? && selected_values(answers[input_name]).include?(value.parameterize)
  end

  private

  def selected_values(answer)
    Array(answer).map { |value| value.to_s.parameterize }.reject(&:blank?)
  end
end
