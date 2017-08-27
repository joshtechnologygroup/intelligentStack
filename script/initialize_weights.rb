#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

$redis.hmset('skill_weights', 'upvote', 5, 'downvote', -1, 'score_to_view', 5, 'is_accepted', 2)
$redis.hmset('question_rank_weights', 'score', 10, 'answers', 5, 'max_score', 2, 'favorites', 5, 'upvote', 10, 'downvote', -100)
