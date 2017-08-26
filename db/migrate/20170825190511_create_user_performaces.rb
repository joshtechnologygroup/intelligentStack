class CreateUserPerformaces < ActiveRecord::Migration[5.1]
  def change
    create_table :user_performaces do |t|
      t.string :user_id
      t.string :question_id
      t.string :answer_id
      t.string :tags, array: true
      t.string :question_keywords, array: true
      t.integer :upvotes
      t.integer :downvotes
      t.boolean :accepted
      t.integer :view_count
      t.timestamps
    end
  end
end
