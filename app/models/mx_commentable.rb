module MxCommentable
  extend ActiveSupport::Concern

  included do
    after_save :save_comment
    has_one :mx_comment, as: :comment_owner
  end

  def comment
    mx_comment.try(:comment) || @comment
  end

  def comment=(comment)
    if mx_comment
      mx_comment.comment = comment
    else
      @comment = comment
    end
  end

  private

  def save_comment
    if mx_comment
      mx_comment.save
    elsif @comment.present?
      MxComment.create(comment_owner_id: self.id,
                       comment_owner_type: self.class.name,
                       comment: @comment)
    end
  end
end
