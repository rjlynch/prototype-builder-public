# Backs the per-component editor forms in the builder. One class covers all
# kinds: each kind's editor only renders (and so only submits) the fields
# that apply to it.
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
      hint: component.hint
    )
  end

  attr_accessor :component, :text, :name, :label, :hint

  validates :text, :name, :label, :hint, length: { maximum: 5_000 }

  def save
    return false unless valid?

    component.update!(text: text, name: name, label: label, hint: hint)
    true
  end
end
