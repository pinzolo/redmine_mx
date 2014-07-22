module MxTaggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :mx_taggable, class_name: 'MxTagging'
    has_many :tags, through: :taggings
  end

  def add_tag(name)
    return if tags.where(name: name).exists?

    tag = MxTag.where(name: name).first || MxTag.new(name: name)
    tags << tag
  end

  def remove_tag(name)
    tag = MxTag.where(name: name).first
    tags.delete(tag) if tag && tags.include?(tag)
  end
end
