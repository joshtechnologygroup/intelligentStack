class TagScore < ApplicationRecord
  def self.delete_user(user_id)
    self.where(user_id: user_id).destroy_all
  end
end
