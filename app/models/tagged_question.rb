class TaggedQuestion < ApplicationRecord
  def self.get_question(user_id)
    # User.generate_user_performance_data(user_id) Once per user
    tags = TagScore.where(user_id: user_id).order('score DESC')
    for tag in tags
      tag_name = Tag.find_by_id(tag.tag_id).try(:tagname)
      unless tag_name
        next
      end
      # `python lib/scripts/ordering.py -t "#{tag_name}"`
      questions = TaggedQuestion.where("tags LIKE '%#{tag_name}%' and accepted_answer_id is NULL")
      questions.each do |q|
        question_keywords = User.fetch_question_keywords(q.body).flatten
        question_keywords = question_keywords.reject {|v| question_keywords.index(v).odd?}
        question_keywords = valid_question_keywords(question_keywords)
        if question_keywords.present?
          q.tags = q.tags.split(',').push(question_keywords).join(',')
          q.save
        end
      end
      unless questions.blank?
        users = questions.map(&:"owner.user_id").uniq
        users.each do |user|
          User.generate_user_performance_data(1, 1, user) unless TaggedQuestion.find(user_id: user)
        end

        question_rank_weights = $redis.hgetall('question_rank_weights')
        score_weight = question_rank_weights['score'].to_i
        answers_weight = question_rank_weights['answers'].to_i
        max_score_weight = question_rank_weights['max_score'].to_i
        favorites_weight = question_rank_weights['favorites'].to_i
        upvote_weight = question_rank_weights['upvote'].to_i
        downvote_weight = question_rank_weights['downvote'].to_i

        query = "
        INSERT INTO suggested_questions SELECT #{user_id}, question_id, link, COALESCE(b.score, 0)* #{score_weight} + COALESCE(answer_count, 0) * #{answers_weight} +
        COALESCE(max_score, 0) * #{max_score_weight} + COALESCE(favorite_count, 0) * #{favorites_weight} + COALESCE(up_vote_count,0)*#{upvote_weight}
        - COALESCE(down_vote_count, 0)*#{downvote_weight} as sort_column FROM ( select * from questions WHERE (tags LIKE '%ruby%' and accepted_answer_id is NULL) )a JOIN (select * from tag_scores where tag_id ='12') b on a.\"owner.user_id\"=b.user_id::BIGINT WHERE WHERE b.score is NULL or b.score <= #{TagScore.where(tag_id: tag.tag_id,user_id: user_id).first.score} ;
        select * from q_test1 order by sort_column desc;"
        ActiveRecord::Base.connection.execute(query)
        break
      end
    end
  end
end
