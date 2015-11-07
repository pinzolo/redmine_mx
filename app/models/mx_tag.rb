class MxTag < ActiveRecord::Base
  include MxAssocOpts
  unloadable

  has_many :taggings, *assoc_opts(order: :name,
                                  class_name: 'MxTagging',
                                  foreign_key: :tag_id,
                                  dependent: :destroy)
end
