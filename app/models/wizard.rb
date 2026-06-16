class Wizard < ApplicationRecord
  belongs_to :team
  has_many :pages, -> { order(:position) }, dependent: :destroy, inverse_of: :wizard

  validates :name, presence: true

  # Every input answer key across the whole wizard, for branch rules and
  # answer whitelisting.
  def input_keys
    Component.inputs
      .joins(:page)
      .where(pages: { wizard_id: id })
      .pluck(:name)
      .map { |name| name.to_s.parameterize }
      .uniq
      .sort
  end

  # [display text, answer key] pairs for branch-rule selects: the key plus
  # the question it belongs to ("question-1 (Are you eligible?)"), so the
  # generated names mean something to the person picking one.
  def input_choices
    inputs = Component.inputs.includes(:page).where(pages: { wizard_id: id }).references(:page)
    choices = inputs.each_with_object({}) do |input, seen|
      key = input.input_key
      context = input.label.presence || input.page.title.presence
      seen[key] ||= [ context ? "#{key} (#{context})" : key, key ]
    end
    choices.values.sort_by(&:last)
  end
end
