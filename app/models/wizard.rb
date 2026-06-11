class Wizard < ApplicationRecord
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
end
