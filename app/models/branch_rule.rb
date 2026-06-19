# One branch on a button: "go to page Z when these conditions all hold". A
# rule holds one or more conditions, ANDed together. Rules (and their
# conditions) are filled in gradually, so a rule only takes part in matching
# once it has a target page and at least one complete condition.
class BranchRule < ApplicationRecord
  belongs_to :component
  has_many :conditions, -> { order(:position) }, dependent: :destroy, inverse_of: :branch_rule

  validates :position,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :component_id }
  validates :target_slug, length: { maximum: 5_000 }

  def complete?
    target_slug.present? && live_conditions.any?
  end

  def missing_target?
    return false if target_slug.blank?

    component.page.wizard.pages.where(slug: target_slug).none?
  end

  # AND semantics: every complete condition must match. Conditions still being
  # filled in (blank) are ignored, so the rule fires as soon as the conditions
  # the builder has completed all match.
  def matches?(answers)
    complete? && live_conditions.all? { |condition| condition.matches?(answers) }
  end

  private

  def live_conditions
    conditions.select(&:complete?)
  end
end
