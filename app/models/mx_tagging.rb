class MxTagging < ActiveRecord::Base
  unloadable

  belongs_to :tag, class_name: 'MxTag'
  belongs_to :mx_taggable, polymorphic: true
end
