class User < ApplicationRecord
  has_many :posts, class_name: 'Post', primary_key: 'id', foreign_key: 'owneruserid'

  def self.generate_user_performance_data(start_page, end_page, user_so_id)
    TagScore.where(user_id: user_so_id).destroy_all
    user_answers = []
    for page in start_page..end_page do
      user_answers.push(fetch_user_answers(user_so_id, page))
    end

    user_answers = user_answers.flatten
    user_answers.each do |answer|
      question_id = answer["question_id"]
      question = fetch_user_question(question_id)
      question_keywords = fetch_question_keywords(question["body"]).flatten
      question_keywords = question_keywords.reject {|v| question_keywords.index(v).odd?}
      question_keywords = valid_question_keywords(question_keywords)
        UserPerformace.create(
          user_id: user_so_id.to_s,
          question_id: question_id.to_s,
          answer_id: answer["answer_id"].to_s,
          tags: question["tags"],
          question_keywords: fetch_question_keywords(question["body"]),
          upvotes: answer["up_vote_count"].to_i,
          downvotes: answer["down_vote_count"].to_i,
          accepted: answer["is_accepted"],
          view_count: question["view_count"].to_i,
          question_keywords: question_keywords
        )
        all_tags = question["tags"] | question_keywords
        all_tags.each do |tag|
          weight = 0
          weight += $redis.hget('skill_weights','upvote').to_i if answer["up_vote_count"].to_i > 0
          weight += $redis.hget('skill_weights','downvote') if answer["down_vote_count"].to_i > 0
          weight += $redis.hget('skill_weights','score_to_view') if ((answer["up_vote_count"].to_i - answer["down_vote_count"].to_i) * 1000 / question["view_count"].to_i > 0)
          weight += $redis.hget('skill_weights','is_accepted') if answer["is_accepted"]
          tag_name = TagSynonym.find_by_sourcetagname(tag).try(:targettagname)
          target_tag = Tag.find_by_tagname(tag_name || tag)
          tag_score = TagScore.where(user_id: user_so_id, tag_id: target_tag.id).first
          if(tag_score)
            current_score = tag_score.score
            tag_score.update_attributes(score: current_score + weight)
          else
            TagScore.create(user_id: user_so_id, tag_id: target_tag.id, score: weight)
          end
        end
    end

  end

  def self.fetch_user_answers(user_so_id, page)
    url = "https://api.stackexchange.com/2.2/users/#{user_so_id}/answers?page=#{page}&pagesize=15&order=desc&sort=activity&site=stackoverflow&filter=!-*f(6t*ZbDla&access_token=0bwAYzM3ae4ZzQs1o5R73Q))&key=*aiCyheCAqPgs8YUmUVEzA(("
    JSON.parse(RestClient.get(url, headers={}).body)["items"]
  end

  def self.fetch_user_question(question_id)
    url = "https://api.stackexchange.com/2.2/questions/#{question_id}?page=1&pagesize=100&order=desc&sort=activity&site=stackoverflow&filter=!9YdnSJ*Wh&access_token=0bwAYzM3ae4ZzQs1o5R73Q))&key=*aiCyheCAqPgs8YUmUVEzA(("
    question = JSON.parse(RestClient.get(url, headers={}).body)["items"]
    question[0]
  end

  def self.fetch_question_keywords(question_body)
    question_body = Nokogiri::HTML(question_body).text.gsub("\n", '').to_s
    url = "https://apis.paralleldots.com/keywords?q=#{question_body}&apikey=OLdsBf7547Eul5AKmElfoGIk5YhMqe29HfovPT7fSBQ"
    url = URI.encode(url)
    JSON.parse(RestClient.post(url, headers={}))
  rescue => e
    []
  end

  def self.valid_question_keywords(suggestions)
    valid_keywords = []
    keywords = []
    suggestions.each do |suggestion|
      suggestion.split(' ').each do |keyword|
        keywords.push(keyword)
      end
    end

    keywords.each do |keyword|
      tag_name = TagSynonym.find_by_sourcetagname(keyword).try(:targettagname)
      target_tag = Tag.find_by_tagname(tag_name || keyword)
      valid_keywords.push(target_tag.tagname) if target_tag
    end
    valid_keywords
  end
end
