# Appends a component of the given kind to a page, with per-kind defaults
# (e.g. buttons start as "Continue", per the brief).
class AddComponentForm
  include ActiveModel::Model

  DEFAULTS = {
    "paragraph" => { text: "" },
    "text_input" => { name: "", label: "", hint: "" },
    "button" => { text: "Continue" }
  }.freeze

  attr_accessor :page, :kind
  attr_reader :component

  validates :page, presence: true
  validates :kind, inclusion: { in: Component::KINDS }

  def save
    return false unless valid?

    position = (page.components.maximum(:position) || 0) + 1
    @component = page.components.create!(kind: kind, position: position, **DEFAULTS.fetch(kind))
    true
  end
end
