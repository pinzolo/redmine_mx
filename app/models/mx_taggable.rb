module MxTaggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :mx_taggable, class_name: 'MxTagging'
    has_many :tags, through: :taggings
  end

  def add_tag(name)
    return if self.tags.where(name: name).exists?

    tag = MxTag.where(name: name).first || MxTag.new(name: name)
    self.tags << tag
  end

  def remove_tag(name)
    tag = MxTag.where(name: name).first
    self.tags.delete(tag) if tag && self.tags.include?(tag)
  end
end
