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

  # Answer keys for checkbox inputs — the groups that submit an array of
  # values (answers[key][]) rather than a single string, so the answers
  # controller can permit them as arrays.
  def checkbox_input_keys
    Component.where(kind: "checkboxes")
      .joins(:page)
      .where(pages: { wizard_id: id })
      .pluck(:name)
      .map { |name| name.to_s.parameterize }
      .uniq
      .sort
  end

  # input_key => the first input component carrying that key, in journey order
  # (page then component position). The check_answers summary uses it to resolve
  # each chosen key to its question: the component's label is the row key, its
  # page the Change-link target, and it formats its own stored answer.
  def input_index
    Component.inputs.includes(:page)
      .where(pages: { wizard_id: id }).references(:page)
      .sort_by { |component| [ component.page.position, component.position ] }
      .each_with_object({}) { |component, index| index[component.input_key] ||= component }
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

  # [display text, answer key] pairs for the file-playback component's select:
  # only the wizard's file upload inputs, each labelled with the question it
  # belongs to. Mirrors input_choices but narrowed to uploads.
  def file_upload_choices
    uploads = Component.where(kind: "file_upload").includes(:page)
      .where(pages: { wizard_id: id }).references(:page)
    choices = uploads.each_with_object({}) do |input, seen|
      key = input.input_key
      context = input.label.presence || input.page.title.presence
      seen[key] ||= [ context ? "#{key} (#{context})" : key, key ]
    end
    choices.values.sort_by(&:last)
  end

  # Fixed answers per input key, for inputs whose answers come from a set
  # (radios, checkboxes). The condition editor offers these as a datalist so a
  # branch answer can be picked the way the question is; text inputs are absent
  # (left as free text). First component for a key wins, mirroring input_choices.
  def answer_options
    components = Component.where(kind: %w[ radios checkboxes ])
      .joins(:page).where(pages: { wizard_id: id })
    components.each_with_object({}) do |component, options|
      options[component.input_key] ||= component.option_list
    end
  end

  # Every page slug in the wizard (position order), for the "Go to page"
  # datalists on buttons and branch rules.
  def page_slugs
    pages.pluck(:slug)
  end
end
