class Post < ApplicationRecord
  belongs_to :user, class_name: 'User', foreign_key: 'owneruserid', primary_key: 'id'
end
