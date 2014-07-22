module MxCommentable
  extend ActiveSupport::Concern

  included do
    after_save :save_comment
    has_one :mx_comment, as: :mx_commentable
  end

  def comment
    mx_comment.try(:comment)
  end

  def comment=(comment)
    build_mx_comment unless mx_comment
    mx_comment.comment = comment
  end

  private

  def save_comment
    if mx_comment.try(:comment)
      mx_comment.save
    else
      mx_comment.try(:destroy)
    end
  end
end
