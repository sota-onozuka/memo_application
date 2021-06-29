# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'fileutils'
require 'dotenv/load'
require 'pg'

enable :method_override

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

class Memo
  class << self
    def connect_to_db(db_name)
      @connection = PG.connect(dbname: db_name)
    end

    def create(title: memo_title, content: memo_content)
      @connection.exec_prepared('create', [title, content])
      cv = @connection.exec("SELECT currval('memo_id_seq');")
      cv.each do |i|
        @id = i["currval"]
      end
      @id
    end

    def read(id = nil)
      if id.nil?
        results = @connection.exec('select * from memo')
      else
        results = @connection.exec_prepared('select_to_read', [id.to_i])
      end
      ls = []
      results.each do |result|
        ls.push(result)
      end
      ls
    end

    def edit(id: memo_id, title: memo_title, content: memo_content)
      @connection.prepare('update', 'update memo set title = $1, content = $2 where id = $3')
      @connection.exec_prepared('update', [title, content, id.to_i])
    end

    def delete(id)
      @connection.exec_prepared('delete', [id.to_i])
    end
  end
end

before do
  @connection = Memo.connect_to_db('memos') #connect_to_dbと分けるのは構造化プログラミングのためか、、、？質問する。
  @connection.prepare('create', 'insert into memo(title, content) values ($1,$2);')
  @connection.prepare('select_to_read', 'select * from memo where id = $1;')
  @connection.prepare('delete', 'delete from memo where id = $1;')
end

get '/' do
  @memos = Memo.read
  erb :index
end

delete '/memo/:id/delete' do
  Memo.delete(params[:id].to_i)
  redirect to('/'), 303
end

get '/create_memo' do
  erb :create_memo
end

post '/confirm' do
  @id = Memo.create(title: params[:title], content: params[:content])
  redirect to("/memo/#{@id}"), 303
end


get '/memo/:id/edit' do
  @memo = Memo.read(params[:id])[0]
  erb :edit_memo
end

get '/memo/:id' do
  @memo = Memo.read(params[:id])[0]
  erb :memo
end

patch '/confirm_edit/:id' do
  Memo.edit(id: params[:id], title: params[:title], content: params[:content])
  redirect to("/memo/#{params[:id]}"), 303
end

not_found do
  '存在しないページにリクエストしています'
end
