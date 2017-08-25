class User < ApplicationRecord
  has_many :posts, class_name: 'Post', primary_key: 'id', foreign_key: 'owneruserid'
end
