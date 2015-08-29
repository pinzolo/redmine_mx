class MxTag < ActiveRecord::Base
  unloadable

  has_many :taggings, ->{ order(:name) },
                      class_name: 'MxTagging',
                      foreign_key: :tag_id,
                      dependent: :destroy
end
