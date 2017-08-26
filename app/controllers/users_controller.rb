class UsersController < ApplicationController
  def create_skill_sets
    User.generate_user_performance_data(1,1, 656769)
  end

  def get_questions
    # `python lib/scripts/ordering.py`
    # User.generate_user_performance_data(1,1, 6534673)
    TaggedQuestion.get_question(6534673)
  end
end
