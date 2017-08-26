class UsersController < ApplicationController
  def create_skill_sets
    User.generate_user_performance_data(1,1, 656769)
  end

  def get_questions
    # `python lib/scripts/ordering.py`
    create_skill_sets
  end

  private

  def fetch_user_answers(user_so_id, page)
    url = "https://api.stackexchange.com/2.2/users/#{user_so_id}/answers?page=#{page}&pagesize=100&order=desc&sort=activity&site=stackoverflow&filter=!-*f(6t*ZbDla&access_token=6je(iFBSCURskSMOJrJMig))&key=*aiCyheCAqPgs8YUmUVEzA(("
    JSON.parse(RestClient.get(url, headers={}).body)["items"]
  end

  def fetch_user_question(question_id)
    url = "https://api.stackexchange.com/2.2/questions/#{question_id}?page=1&pagesize=100&order=desc&sort=activity&site=stackoverflow&filter=!9YdnSJ*Wh&access_token=6je(iFBSCURskSMOJrJMig))&key=*aiCyheCAqPgs8YUmUVEzA(("
    question = JSON.parse(RestClient.get(url, headers={}).body)["items"]
    question[0]
  end

  def fetch_question_keywords(question_body)
    []
  end
end
