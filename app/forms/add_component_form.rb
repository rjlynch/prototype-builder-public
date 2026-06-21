# Appends a component of the given kind to a page, with per-kind defaults
# (e.g. buttons start as "Continue", per the brief). Inputs always get a
# name, generated unique within the wizard, so answers and branch rules can
# reference them from the moment they exist.
class AddComponentForm
  include ActiveModel::Model

  DEFAULTS = {
    "paragraph" => { text: "" },
    "subheading" => { text: "" },
    "list" => { text: "" },
    "text_input" => { label: "", hint: "" },
    "radios" => { label: "", hint: "", options: "" },
    "checkboxes" => { label: "", hint: "", options: "" },
    "file_upload" => { label: "", hint: "" },
    "button" => { text: "Continue" }
  }.freeze

  attr_accessor :page, :kind
  attr_reader :component

  validates :page, presence: true
  validates :kind, inclusion: { in: Component::KINDS }

  def save
    return false unless valid?

    attributes = DEFAULTS.fetch(kind).dup
    attributes[:name] = generated_name if Component::INPUT_KINDS.include?(kind)
    position = (page.components.maximum(:position) || 0) + 1
    @component = page.components.create!(kind: kind, position: position, **attributes)
    true
  end

  private

  def generated_name
    taken = page.wizard.input_keys
    number = 1
    number += 1 while taken.include?("question-#{number}")
    "question-#{number}"
  end
end
