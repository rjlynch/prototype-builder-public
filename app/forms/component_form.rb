# Backs the per-component editor forms in the builder. One class covers all
# kinds: each kind's editor only renders (and so only submits) the fields
# that apply to it, and unsubmitted attributes keep their current values
# (the controller builds the form from the component before assigning params).
class ComponentForm
  include ActiveModel::Model

  def self.model_name
    ActiveModel::Name.new(self, nil, "Component")
  end

  def self.from_component(component)
    new(
      component: component,
      text: component.text,
      name: component.name,
      label: component.label,
      hint: component.hint,
      options: component.options,
      title_as_label: component.title_as_label
    )
  end

  attr_accessor :component, :text, :name, :label, :hint, :options, :title_as_label

  validates :text, :name, :label, :hint, :options, length: { maximum: 5_000 }
  validates :name, presence: true, if: -> { component&.input? }

  def save
    return false unless valid?

    component.update!(
      text: text, name: name, label: label, hint: hint, options: options,
      title_as_label: title_as_label
    )
    true
  end
end
