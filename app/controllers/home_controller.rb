require 'stack_api'

class HomeController < ApplicationController
  def index
    @unanswered_post = StackApi.get_unanswered_post
    @title = @unanswered_post['title']
    @link = @unanswered_post['link']
    @id = @unanswered_post['question_id']
    $redis.hset(@current_user_id, @id, Time.now.to_i)
  end

  private

  def all_answers(ids)
    url = "https://api.stackexchange.com/2.2//questions/#{ids.join(';')}/answers?site=stackoverflow&key=BipPk3LoVirifKeqxobNlw(("
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res = http.get(uri.request_uri)
    answers = JSON.parse(res.body)['items']
    (answers || []).select{ |k,v| k['owner']['user_id'] == 157247 }
  end

  def adjust_weights
    current = Time.now.to_i
    questions_to_time =  $redis.hgetall(@current_user_id)
    q_ids = questions_to_time.select{ |k,v| v.to_i > current - 2.months}.keys

    #delete stale questions i.e. which are older than 2 months
    (questions_to_time.keys - q_ids).each{ |q| $redis.hdel(q_id) }

    puts "question_ids", q_ids

    answers = all_answers(q_ids)

    exit if answers.blank?

    skill_weights = $redis.hgetall('skill_weights')
    question_rank_weights = $redis.hgetall('question_rank_weights')

    #decision tree
    answers.each do |ans|
      score = ans['score'].to_i
      created_at = ans['creation_date']
      is_accepted = ans['is_accepted']

      time_diff = created_at - questions_to_time[ans['question_id']].to_i

      observed_upvote_skill_weight = skill_weights['upvote'].to_i
      observed_downvote_skill_weight = skill_weights['downvote'].to_i
      observed_score_to_view_skill_weight = skill_weights['score_to_view'].to_i
      observed_is_accepted_skill_weight = skill_weights['is_accepted'].to_i

      observed_score = observed_upvote_skill_weight + observed_downvote_skill_weight + observed_score_to_view_skill_weight + observed_is_accepted_skill_weight
      actual_score = (observed_score - score).abs * (score / time_diff)
      actual_score = observed_score * (score / time_diff) if is_accepted == 'true'

      diff = actual_score - observed_score

      actual_upvote_skill_weight = observed_upvote_skill_weight + observed_upvote_skill_weight * diff.to_f/time_diff.to_f
      actual_downvote_skill_weight = observed_downvote_skill_weight + observed_downvote_skill_weight * diff.to_f/time_diff.to_f
      actual_score_to_view_skill_weight = observed_score_to_view_skill_weight + observed_score_to_view_skill_weight * diff.to_f/time_diff.to_f
      actual_is_accepted_skill_weight = observed_is_accepted_skill_weight + observed_is_accepted_skill_weight * diff.to_f/time_diff.to_f

      $redis.hmset('skill_weights',
                   'upvote',
                   actual_upvote_skill_weight,
                   'downvote',
                   actual_downvote_skill_weight,
                   'score_to_view',
                   actual_score_to_view_skill_weight,
                   'is_accepted',
                   actual_is_accepted_skill_weight)

      observed_score_question_rank_weight = question_rank_weights['score'].to_i
      observed_answers_question_rank_weight = question_rank_weights['answers'].to_i
      observed_max_score_question_rank_weight = question_rank_weights['max_score'].to_i
      observed_favorites_question_rank_weight = question_rank_weights['favorites'].to_i
      observed_upvote_question_rank_weight = question_rank_weights['upvote'].to_i
      observed_downvote_question_rank_weight = question_rank_weights['downvote'].to_i

      actual_score_question_rank_weight = observed_score_question_rank_weight + observed_score_question_rank_weight * diff.to_f/time_diff.to_f
      actual_answers_question_rank_weight = observed_answers_question_rank_weight + observed_answers_question_rank_weight * diff.to_f/time_diff.to_f
      actual_max_score_question_rank_weight = observed_max_score_question_rank_weight + observed_max_score_question_rank_weight * diff.to_f/time_diff.to_f
      actual_favorites_question_rank_weight = observed_favorites_question_rank_weight + observed_favorites_question_rank_weight * diff.to_f/time_diff.to_f
      actual_upvote_question_rank_weight = observed_upvote_question_rank_weight + observed_upvote_question_rank_weight * diff.to_f/time_diff.to_f
      actual_downvote_question_rank_weight = observed_downvote_question_rank_weight + observed_downvote_question_rank_weight * diff.to_f/time_diff.to_f

      $redis.hmset('question_rank_weights',
                   'score',
                   actual_score_question_rank_weight,
                   'answers',
                   actual_answers_question_rank_weight,
                   'max_score',
                   actual_max_score_question_rank_weight,
                   'favorites',
                   actual_favorites_question_rank_weight,
                   'upvote',
                   actual_upvote_question_rank_weight,
                   'downvote',
                   actual_downvote_question_rank_weight)
    end
  end
end
