begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  gem 'rails', github: 'rails/rails'
  gem 'arel', github: 'rails/arel'
  gem 'sqlite3'
end

require 'active_record'
require 'minitest/autorun'
require 'logger'

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts, force: true  do |t|
  end

  create_table :comments, force: true  do |t|
    t.integer :post_id
  end

  create_table :replies, force: true do |t|
    t.integer :comment_id
  end

  create_table :subreplies, force: true do |t|
    t.integer :reply_id
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
  has_many :replies
end

class Reply < ActiveRecord::Base
  belongs_to :comment
  has_many :subreplies
end

class Subreply < ActiveRecord::Base
  belongs_to :reply

  has_one :comment, through: :reply, source: :comment
  has_one :post, through: :comment, source: :post
end

class BugTest < Minitest::Test
  def test_association_stuff
    post = Post.create!
    comment = Comment.create!(post: post)
    reply = Reply.create!(comment: comment)
    subreply = Subreply.new(reply: reply)

    subreply.comment

    # assert_equal 1, post.comments.count
    # assert_equal 1, Comment.count
    # assert_equal post.id, Comment.first.post.id
  end
end
