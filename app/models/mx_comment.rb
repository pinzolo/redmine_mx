class MxComment < ActiveRecord::Base
  unloadable

  belongs_to :mx_commentable, polymorphic: true
end
