class UsersController < ApplicationController
  def create_skill_sets
    user_so_id = 656769
    user_answers = []

    for page in 1..1 do
      user_answers.push(fetch_user_answers(user_so_id, page))
    end

    user_answers = user_answers.flatten
    user_answers.each do |answer|
        question_id = answer["question_id"]
        question = fetch_user_question(question_id)
        UserPerformace.create(
          user_id: user_so_id.to_s,
          question_id: question_id.to_s,
          answer_id: answer["answer_id"].to_s,
          tags: question["tags"],
          question_keywords: fetch_question_keywords(question["body"]),
          upvotes: answer["up_vote_count"].to_i,
          downvotes: answer["down_vote_count"].to_i,
          accepted: answer["is_accepted"],
          view_count: question["view_count"].to_i
        )
    end
  end

  private

  def fetch_user_answers(user_so_id, page)
    url = "https://api.stackexchange.com/2.2/users/#{user_so_id}/answers?page=#{page}&pagesize=10&order=desc&sort=activity&site=stackoverflow&filter=!-*f(6t*ZbDla"
    JSON.parse(RestClient.get(url, headers={}).body)["items"]
  end

  def fetch_user_question(question_id)
    url = "https://api.stackexchange.com/2.2/questions/#{question_id}?page=1&pagesize=100&order=desc&sort=activity&site=stackoverflow&filter=!9YdnSJ*Wh"
    question  = JSON.parse(RestClient.get(url, headers={}).body)["items"]
    question[0]
  end

  def fetch_question_keywords(question_body)
    question_body = Nokogiri::HTML(question_body).text.gsub("\n", '').to_s
    url = "https://apis.paralleldots.com/keywords?q=#{question_body}&apikey=OLdsBf7547Eul5AKmElfoGIk5YhMqe29HfovPT7fSBQ"
    url = URI.encode(url)
    JSON.parse(RestClient.post(url, headers={}))
  rescue => e
    []
  end
end
