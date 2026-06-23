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
      title_as_label: component.title_as_label,
      list_style: component.list_style,
      list_spaced: component.list_spaced,
      button_style: component.button_style,
      target_slug: component.target_slug,
      in_panel: component.in_panel,
      inline: component.inline,
      source_key: component.source_key,
      display_as_link: component.display_as_link,
      summary_keys: component.summary_keys
    )
  end

  attr_accessor :component, :text, :name, :label, :hint, :options, :title_as_label,
    :list_style, :list_spaced, :button_style, :target_slug, :in_panel, :inline,
    :source_key, :display_as_link, :summary_keys

  validates :text, :name, :label, :hint, :options, :target_slug, :source_key, length: { maximum: 5_000 }
  validates :name, presence: true, if: -> { component&.input? }
  validates :list_style, inclusion: { in: Component::LIST_STYLES }
  validates :button_style, inclusion: { in: Component::BUTTON_STYLES }
  validate :single_page_heading, if: -> { component && wants_title_as_label? }

  def save
    return false unless valid?

    component.update!(
      text: text, name: name, label: label, hint: hint, options: options,
      title_as_label: title_as_label, list_style: list_style, list_spaced: list_spaced,
      button_style: button_style, target_slug: target_slug.to_s.parameterize,
      in_panel: in_panel, inline: inline,
      source_key: source_key, display_as_link: display_as_link,
      summary_keys: summary_keys_value
    )
    true
  end

  private

  # The summary list submits its chosen question keys as `summary_keys` (an
  # array, with an empty entry so clearing every box still submits a value);
  # they are stored one per line. Other kinds carry the component's existing
  # value (a string) straight through — Array() wraps it untouched.
  def summary_keys_value
    Array(summary_keys).reject(&:blank?).join("\n")
  end

  def wants_title_as_label?
    ActiveModel::Type::Boolean.new.cast(title_as_label)
  end

  # Only one input per page may render the title as its label/legend —
  # a page has one H1. (Also validated on the model.)
  def single_page_heading
    return unless component.page.components.where(title_as_label: true).where.not(id: component.id).exists?

    errors.add(:title_as_label, "is already in use on this page")
  end
end
