# Deletes a page (with its components) and renumbers the wizard's remaining
# pages contiguously from 1. A wizard always keeps at least one page. Branch
# rules that pointed at the deleted slug stop matching anything and fall
# back to linear continuation.
class DeletePageForm
  include ActiveModel::Model

  attr_accessor :page

  validate :not_the_only_page

  # The page to show once this one is gone: its predecessor, or the new
  # first page.
  def destination
    @destination ||=
      sibling_pages.where(position: ...page.position).order(:position).last ||
      sibling_pages.order(:position).first
  end

  def save
    return false unless valid?

    destination # memoise before the page is gone
    Page.transaction do
      page.destroy!
      renumber
    end
    true
  end

  private

  def sibling_pages
    page.wizard.pages.where.not(id: page.id)
  end

  def not_the_only_page
    errors.add(:page, "is the only page in this wizard") if sibling_pages.none?
  end

  # Walk the survivors in position order, pulling each down into the lowest
  # free slot. Always moving a page downwards into a vacated position keeps
  # the unique [wizard_id, position] index happy mid-transaction.
  def renumber
    page.wizard.pages.reload.each.with_index(1) do |sibling, index|
      sibling.update!(position: index) unless sibling.position == index
    end
  end
end
