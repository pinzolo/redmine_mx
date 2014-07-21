class MxComment < ActiveRecord::Base
  unloadable

  belongs_to :comment_owner, polymorphic: true
end
