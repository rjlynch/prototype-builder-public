# Backs the builder's page settings: title and slug, each submitted by its
# own small form (so only the attributes present in params are touched).
#
# Slug behaviour: it tracks the title ("What is your name" -> what-is-your-name)
# for as long as it still looks auto-derived (the default page-N, or derived
# from the previous title). Once the user edits the slug field themselves it
# stops tracking. Slugs are parameterised and silently uniquified per wizard.
class PageForm
  include ActiveModel::Model

  def self.model_name
    ActiveModel::Name.new(self, nil, "Page")
  end

  def self.from_page(page)
    new(page: page, title: page.title, slug: page.slug)
  end

  attr_accessor :page
  attr_reader :title, :slug

  validates :title, length: { maximum: 500 }
  validates :slug, length: { maximum: 200 }

  def title=(value)
    @title = value
    @title_submitted = true
  end

  def slug=(value)
    @slug = value
    @slug_submitted = true
  end

  def save
    return false unless valid?

    page.title = title if @title_submitted
    page.slug = resolve_slug
    page.save!
    true
  end

  private

  def resolve_slug
    if @slug_submitted
      base = slug.to_s.parameterize.presence || derived_slug
      Page.unique_slug(page.wizard, base, except: page)
    elsif @title_submitted && page.title_changed? && auto_slugged?
      Page.unique_slug(page.wizard, derived_slug, except: page)
    else
      page.slug
    end
  end

  def derived_slug
    page.title.to_s.parameterize.presence || Page.default_slug(page.position)
  end

  # The slug still looks like one we generated (default, or derived from the
  # title before this change, possibly with a -N uniqueness suffix).
  def auto_slugged?
    old = page.title_was.to_s.parameterize
    page.slug.blank? ||
      page.slug == old ||
      (old.present? && page.slug =~ /\A#{Regexp.escape(old)}-\d+\z/) ||
      page.slug =~ /\Apage-\d+\z/
  end
end
