class User < ApplicationRecord
  has_many :posts, class_name: 'Post', primary_key: 'id', foreign_key: 'owneruserid'

  def generate_user_performance_data(start_page, end_page, user_so_id)
    user_answers = []
    for page in start_page..end_page do
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

        question["tags"].each do |tag|
          weight = 0
          weight += 5 if answer["up_vote_count"].to_i > 0
          weight -= 1 if answer["down_vote_count"].to_i > 0
          weight += 5 if ((answer["up_vote_count"].to_i - answer["down_vote_count"].to_i) * 1000 / question["view_count"].to_i > 0)
          weight += 2 if answer["is_accepted"]
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
end
