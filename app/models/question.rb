class Question < ApplicationRecord
  def self.get_question(user_id)
    # User.generate_user_performance_data(user_id) Once per user
    tags = TagScore.where(user_id: 656769).order(:score)
    for tag in tags
      tag_name = Tag.find(tag.id).tagname
      questions = Question.where("tags LIKE '%?%'", tag_name).order(:)
      unless questions.blank?
        ordered
        break
      end
    end
  end
end
