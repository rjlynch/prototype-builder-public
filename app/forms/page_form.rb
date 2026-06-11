# Backs the builder's page settings (currently just the title).
class PageForm
  include ActiveModel::Model

  def self.model_name
    ActiveModel::Name.new(self, nil, "Page")
  end

  def self.from_page(page)
    new(page: page, title: page.title)
  end

  attr_accessor :page, :title

  validates :title, length: { maximum: 500 }

  def save
    return false unless valid?

    page.update!(title: title)
    true
  end
end
