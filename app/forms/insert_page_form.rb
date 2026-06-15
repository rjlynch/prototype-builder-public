# Inserts a new blank page immediately after the given page, shifting the
# pages that follow it down by one. The new page gets a position-based default
# slug made unique within the wizard; existing pages keep their slugs, so
# branch rules are unaffected.
class InsertPageForm
  include ActiveModel::Model

  attr_reader :page, :new_page

  validates :page, presence: true

  def initialize(page)
    @page = page
  end

  def save
    return false unless valid?

    new_position = page.position + 1
    Page.transaction do
      shift_pages_after(page.position)
      @new_page = page.wizard.pages.create!(
        position: new_position,
        slug: Page.unique_slug(page.wizard, Page.default_slug(new_position))
      )
    end
    true
  end

  private

  # Bump the trailing pages down by one, highest position first so each moves
  # into an already-vacated slot and never collides with the unique
  # [wizard_id, position] index.
  def shift_pages_after(position)
    page.wizard.pages.where("position > ?", position).reorder(position: :desc).each do |sibling|
      sibling.update!(position: sibling.position + 1)
    end
  end
end
