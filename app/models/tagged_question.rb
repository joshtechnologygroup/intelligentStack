class TaggedQuestion < ApplicationRecord
  def self.get_question(user_id)
    # User.generate_user_performance_data(user_id) Once per user
    tags = TagScore.where(user_id: user_id).order('score DESC')
    for tag in tags
      tag_name = Tag.find_by_id(tag.tag_id).try(:tagname)
      unless tag_name
        next
      end
      `python lib/scripts/ordering.py -t "#{tag_name}"`
      questions = TaggedQuestion.where("tags LIKE '%#{tag_name}%' and accepted_answer_id is NULL")
      unless questions.blank?
        users = questions.map(&:"owner.user_id").uniq
        users.each do |user|
          User.generate_user_performance_data(1, 1, user)
        end
        query = "drop table if exists q_test1;
        create table q_test1 as SELECT question_id, link, b.score * 10 + COALESCE(answer_count, 0) * 5 +
        COALESCE(max_score, 0) * 2 + COALESCE(favorite_count, 0) * 5 + COALESCE(up_vote_count,0)*10
        - COALESCE(down_vote_count, 0)*100 as sort_column FROM ( select * from questions WHERE (tags LIKE '%ruby%' and accepted_answer_id is NULL) )a JOIN (select * from tag_scores where tag_id ='12') b on a.\"owner.user_id\"=b.user_id::BIGINT WHERE b.score <= #{TagScore.where(tag_id: tag.tag_id,user_id: user_id).first.score} ;
        select * from q_test1 order by sort_column desc;"
        a = ActiveRecord::Base.connection.execute(query)
        puts a.inspect
        puts '*'*100
        break
      end
    end
  end
end
