# One "if answer X is Y go to page Z" condition on a button component.
# Rules are filled in gradually via autosubmit, so blanks are allowed;
# only complete rules take part in matching.
class BranchRule < ApplicationRecord
  belongs_to :component

  validates :position,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :component_id }
  validates :input_name, :value, :target_slug, length: { maximum: 5_000 }

  def complete?
    [ input_name, value, target_slug ].all?(&:present?)
  end

  def missing_target?
    return false if target_slug.blank?

    component.page.wizard.pages.where(slug: target_slug).none?
  end

  # Values are compared parameterised so "Yes" matches "yes" — kinder to
  # non-technical builders than exact string matching. The answer is treated
  # as a set: a checkbox group supplies several values and the rule matches
  # when its value is among them; a text or radio answer is a set of one, so
  # membership there is plain equality.
  def matches?(answers)
    complete? && selected_values(answers[input_name]).include?(value.parameterize)
  end

  private

  def selected_values(answer)
    Array(answer).map { |value| value.to_s.parameterize }.reject(&:blank?)
  end
end
