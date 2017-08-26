class UsersController < ApplicationController
  def create_skill_sets
    User.generate_user_performance_data(1,1, 656769)
  end

  def get_questions
    # `python lib/scripts/ordering.py`
    # create_skill_sets
    Question.get_questions(656769)
  end
end
