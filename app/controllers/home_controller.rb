require 'stack_api'

class HomeController < ApplicationController
  def index
    @unanswered_post = StackApi.get_unanswered_post
    @title = @unanswered_post['title']
    @link = @unanswered_post['link']
    @id = @unanswered_post['question_id']
    @redis_quesions = $redis.hgetall('questions')
    $redis.hset('questions', @id, Time.now.to_i)
  end
end
