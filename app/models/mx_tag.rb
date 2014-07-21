class MxTag < ActiveRecord::Base
  unloadable

  has_many :taggings, class_name: 'MxTagging', foreign_key: :tag_id, order: :name, dependent: :destroy
end
