# Backs the builder's page settings: title, slug, heading, caption and back
# link, each submitted by its own small form. Only the fields actually present
# in params are changed — the rest keep the page's current values (the form is
# seeded from the page, so re-saving an unsubmitted field is a no-op).
#
# Slug behaviour: it tracks the title ("What is your name" -> what-is-your-name)
# for as long as it still looks auto-derived (the default page-N, or derived
# from the previous title). Once the user edits the slug field themselves it
# stops tracking. Slugs are parameterised and silently uniquified per wizard.
class PageForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  def self.model_name
    ActiveModel::Name.new(self, nil, "Page")
  end

  attribute :title, :string
  attribute :slug, :string
  attribute :heading_size, :string
  attribute :caption, :string
  attribute :back_link, :boolean

  attr_reader :page

  validates :title, length: { maximum: 500 }
  validates :slug, length: { maximum: 200 }
  validates :caption, length: { maximum: 500 }
  validates :heading_size, inclusion: { in: Page::HEADING_SIZES }

  def initialize(page, params: {})
    @page = page
    @submitted = params.to_h.symbolize_keys
    super(
      @submitted.reverse_merge(
        title: page.title,
        slug: page.slug,
        heading_size: page.heading_size,
        caption: page.caption,
        back_link: page.back_link
      )
    )
  end

  def save
    return false unless valid?

    page.title = title
    page.heading_size = heading_size
    page.caption = caption
    page.back_link = back_link
    page.slug = resolve_slug
    page.save!
    true
  end

  private

  def resolve_slug
    if @submitted.key?(:slug)
      base = slug.to_s.parameterize.presence || derived_slug
      Page.unique_slug(page.wizard, base, except: page)
    elsif page.title_changed? && auto_slugged?
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
