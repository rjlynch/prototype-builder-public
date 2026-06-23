class Component < ApplicationRecord
  KINDS = %w[ paragraph subheading list text_input radios checkboxes file_upload file check_answers button ].freeze
  INPUT_KINDS = %w[ text_input radios checkboxes file_upload ].freeze
  LIST_STYLES = %w[ none bullet number ].freeze
  BUTTON_STYLES = %w[ continue secondary inverse start warning ].freeze

  belongs_to :page
  has_many :branch_rules, -> { order(:position) }, dependent: :destroy, inverse_of: :component

  scope :inputs, -> { where(kind: INPUT_KINDS) }

  validates :kind, inclusion: { in: KINDS }
  validates :list_style, inclusion: { in: LIST_STYLES }
  validates :button_style, inclusion: { in: BUTTON_STYLES }
  validates :target_slug, :source_key, length: { maximum: 5_000 }
  validates :name, presence: true, if: :input?
  validates :position,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :page_id }
  validate :single_page_heading, if: :title_as_label?

  def input?
    INPUT_KINDS.include?(kind)
  end

  # Kinds that may be placed inside a page's panel (alongside the H1).
  def panel_eligible?
    kind.in?(%w[ paragraph subheading ])
  end

  # True when this input supplies the page's H1 (the GOV.UK single-question
  # pattern): the first input on the page with title_as_label set.
  def page_heading?
    title_as_label? && page.heading_component == self
  end

  # Whether the editor should offer the title-as-label option: once any
  # input on the page has taken it, the others stop offering it.
  def title_as_label_available?
    title_as_label? || page.heading_component.nil?
  end

  # One line identifying the component in a collapsed editor card.
  def summary_text
    return page.title if page_heading?
    return source_key.presence || "No file selected" if kind == "file"
    return summary_input_keys.any? ? summary_input_keys.join(", ") : "No questions selected" if kind == "check_answers"

    input? ? label : text
  end

  def display_name
    return "Button" if kind == "button"
    return "Uploaded file" if kind == "file"
    return "Check your answers" if kind == "check_answers"

    kind.humanize
  end

  # The uploaded file this `file` component plays back, resolved from the
  # journey's answers (each file answer is the blob's signed id). Nil when the
  # referenced input has no upload yet, or when nothing's been selected.
  def uploaded_blob(answers)
    ActiveStorage::Blob.find_signed(answers[source_key])
  end

  # The GOV.UK modifier class for this button's style ("continue" is the
  # default button, so it carries no modifier).
  def button_modifier_class
    "govuk-button--#{button_style}" unless button_style == "continue"
  end

  # Start buttons render the GOV.UK arrow icon after their label.
  def start_button?
    button_style == "start"
  end

  # The answer key this input's value is stored and matched under.
  def input_key
    name.to_s.parameterize
  end

  # Radio options, one per line in the options column.
  def option_list
    options.to_s.lines.map(&:strip).reject(&:empty?)
  end

  # Whether an "or" text divider should be rendered before the option at the
  # given index: only the last option, only when the divider is enabled, and
  # only when there are at least two options to divide.
  def divider_before?(index)
    show_divider? && option_list.size > 1 && index == option_list.size - 1
  end

  # The options as the plain text they're stored and matched as — markdown
  # markup reduced to the words it wraps. A branch-rule answer must match this
  # (not the raw markdown), so the condition editor's datalist offers these.
  def option_labels
    option_list.map { |option| plain_text(option) }
  end

  # List items, one per line in the text column.
  def list_items
    text.to_s.lines.map(&:strip).reject(&:empty?)
  end

  # Numbered lists render as an ordered list; everything else as unordered.
  def list_ordered?
    list_style == "number"
  end

  # check_answers: the input keys this summary list plays back, one per line in
  # the summary_keys column.
  def summary_input_keys
    summary_keys.to_s.lines.map(&:strip).reject(&:empty?)
  end

  # This input's stored answer formatted for a summary-list value: the option
  # label the user saw for radios/checkboxes (values are stored parameterised),
  # the uploaded file's name for an upload, the entered text otherwise. A blank
  # or missing answer reads "Not answered".
  def summary_answer(answers)
    value = answers[input_key]
    return "Not answered" if value.blank?

    case kind
    when "radios"
      option_label(value)
    when "checkboxes"
      Array(value).reject(&:blank?).map { |entry| option_label(entry) }.join(", ")
    when "file_upload"
      ActiveStorage::Blob.find_signed(value)&.filename.to_s.presence || "Not answered"
    else
      value
    end
  end

  # Where this button sends the user, given everything answered so far: the
  # first matching rule's target wins; otherwise the button's own specified
  # slug (the "else" branch); nil falls through to the next page linearly.
  def destination_slug(answers)
    branch_rules.detect { |rule| rule.matches?(answers) }&.target_slug.presence || target_slug.presence
  end

  # A button pointing at a slug no page has yet — flagged in the editor (in
  # builder mode the page is created blank when the button is first clicked).
  def missing_target?
    return false if target_slug.blank?

    page.wizard.pages.where(slug: target_slug).none?
  end

  private

  # Maps a stored answer value back to the option label the user saw. Radio and
  # checkbox values are stored parameterised (markdown stripped), so reverse
  # that to show the readable option; falls back to the raw value when nothing
  # matches (e.g. the option was edited after the answer was given).
  def option_label(value)
    match = option_list.find { |option| plain_text(option).parameterize == value }
    match ? plain_text(match) : value
  end

  # The plain-text form of an option's markdown (**bold**/[links] reduced to the
  # words they wrap) — mirrors MarkdownHelper#markdown_to_text, duplicated here
  # so the model can format answers without reaching into a view helper.
  def plain_text(text)
    text.to_s
      .gsub(/\*\*(.+?)\*\*/, '\1')
      .gsub(/\[([^\]]+)\]\(([^)]+)\)/, '\1')
  end

  # Only one input per page may render the title as its label/legend —
  # a page has one H1.
  def single_page_heading
    return if page.blank?
    return unless page.components.where(title_as_label: true).where.not(id: id).exists?

    errors.add(:title_as_label, "is already in use on this page")
  end
end
