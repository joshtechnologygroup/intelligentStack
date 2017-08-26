# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170825190511) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "badges", id: false, force: :cascade do |t|
    t.string "id", limit: 50000
    t.string "userid", limit: 50000
    t.string "name", limit: 50000
    t.string "date", limit: 50000
    t.string "class", limit: 50000
    t.string "tagbased", limit: 50000
  end

  create_table "post_feedbacks", id: false, force: :cascade do |t|
    t.string "id", limit: 50000
    t.string "postid", limit: 50000
    t.string "isanonymous", limit: 50000
    t.string "votetypeid", limit: 50000
    t.string "creationdate", limit: 50000
  end

  create_table "posts", id: false, force: :cascade do |t|
    t.string "id", limit: 50000
    t.integer "posttypeid"
    t.string "acceptedanswerid", limit: 50000
    t.string "parentid", limit: 50000
    t.string "creationdate", limit: 50000
    t.string "deletiondate", limit: 50000
    t.string "score", limit: 50000
    t.string "viewcount", limit: 50000
    t.string "body", limit: 50000
    t.string "owneruserid", limit: 50000
    t.string "ownerdisplayname", limit: 50000
    t.string "lasteditoruserid", limit: 50000
    t.string "lasteditordisplayname", limit: 50000
    t.string "lasteditdate", limit: 50000
    t.string "lastactivitydate", limit: 50000
    t.string "title", limit: 50000
    t.string "tags", limit: 50000
    t.string "answercount", limit: 50000
    t.string "commentcount", limit: 50000
    t.string "favoritecount", limit: 50000
    t.string "closeddate", limit: 50000
    t.string "communityowneddate", limit: 50000
  end

  create_table "tag_synonyms", id: false, force: :cascade do |t|
    t.string "id", limit: 50000
    t.string "sourcetagname", limit: 50000
    t.string "targettagname", limit: 50000
    t.string "creationdate", limit: 50000
    t.string "owneruserid", limit: 50000
    t.string "autorenamecount", limit: 50000
    t.string "lastautorename", limit: 50000
    t.string "score", limit: 50000
    t.string "approvedbyuserid", limit: 50000
    t.string "approvaldate", limit: 50000
  end

  create_table "tags", id: false, force: :cascade do |t|
    t.string "id", limit: 50000
    t.string "tagname", limit: 50000
    t.string "count", limit: 50000
    t.string "excerptpostid", limit: 50000
    t.string "wikipostid", limit: 50000
  end

  create_table "user_performaces", force: :cascade do |t|
    t.string "user_id"
    t.string "question_id"
    t.string "answer_id"
    t.string "tags", array: true
    t.string "question_keywords", array: true
    t.integer "upvotes"
    t.integer "downvotes"
    t.boolean "accepted"
    t.integer "view_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: false, force: :cascade do |t|
    t.string "id", limit: 5000
    t.string "reputation", limit: 5000
    t.string "creationdate", limit: 5000
    t.string "displayname", limit: 5000
    t.string "lastaccessdate", limit: 5000
    t.string "websiteurl", limit: 5000
    t.string "location", limit: 5000
    t.string "aboutme", limit: 5000
    t.string "views", limit: 5000
    t.string "upvotes", limit: 5000
    t.string "downvotes", limit: 5000
    t.string "profileimageurl", limit: 5000
    t.string "emailhash", limit: 5000
    t.string "age", limit: 5000
    t.string "accountid", limit: 5000
  end

  create_table "vote_types", id: false, force: :cascade do |t|
    t.string "id", limit: 50000
    t.string "name", limit: 50000
  end

  create_table "votes", id: false, force: :cascade do |t|
    t.string "id", limit: 50000
    t.string "postid", limit: 50000
    t.string "votetypeid", limit: 50000
    t.string "userid", limit: 50000
    t.string "creationdate", limit: 50000
    t.string "bountyamount", limit: 50000
  end

end
