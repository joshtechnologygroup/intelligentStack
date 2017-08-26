class CreateTagScores < ActiveRecord::Migration[5.1]
  def change
    create_table :tag_scores do |t|
      t.string :user_id
      t.string :tag_id
      t.integer :score
      t.timestamps
    end
  end
end
