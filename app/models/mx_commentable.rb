module MxCommentable
  extend ActiveSupport::Concern

  included do
    after_save :save_comment
    has_one :mx_comment, as: :mx_commentable, dependent: :destroy
  end

  def comment
    @comment || mx_comment.try(:comment)
  end

  def comment=(comment)
    @comment = comment
  end

  private

  def save_comment
    if @comment.presence
      if mx_comment
        mx_comment.update_attributes!(comment: @comment)
      else
        build_mx_comment(comment: @comment).save
      end
    else
      mx_comment.destroy if mx_comment
    end
  end
end
