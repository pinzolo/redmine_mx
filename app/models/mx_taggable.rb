module MxTaggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :mx_taggable, class_name: 'MxTagging'
    has_many :tags, through: :taggings
  end

  def add_tag(name)
    return if tags.where(name: name).exists?

    tags << MxTag.where(name: name).first_or_initialize
  end

  def remove_tag(name)
    tag = MxTag.where(name: name).first
    tags.delete(tag) if tag && tags.include?(tag)
  end
end
