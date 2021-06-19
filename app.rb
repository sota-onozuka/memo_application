# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'fileutils'
require 'dotenv/load'
require 'pg'

enable :method_override
use Rack::Session::Cookie

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

class Memo
  class << self
    def create(id: memo_id, title: memo_title, content: memo_content)
      connection = PG.connect(dbname: 'memos')
      connection.prepare('insert', 'insert into memo(id, title, content) values ($1,$2, $3);')
      connection.exec_prepared('insert', [id, title, content])
    end

    def read(id = nil)
      connection = PG.connect(dbname: 'memos')
      if id.nil?
        results = connection.exec('select * from memo')
      else
        connection.prepare('select', 'select * from memo where id = $1;')
        results = connection.exec_prepared('select', [id.to_i])
      end
      ls = []
      results.each do |result|
        ls.push(result)
      end
      ls
    end

    def edit(id: memo_id, title: memo_title, content: memo_content)
      connection = PG.connect(dbname: 'memos')
      connection.prepare('update', 'update memo set title = $1, content = $2 where id = $3')
      connection.exec_prepared('update', [title, content, id])
    end

    def delete(id)
      connection = PG.connect(dbname: 'memos')
      connection.prepare('delete', 'delete from memo where id = $1;')
      connection.exec_prepared('delete', [id])
    end
  end
end

get '/' do
  @memos = Memo.read
  erb :index
end

delete '/' do
  Memo.delete(session[:id].to_i)
  redirect to('/'), 303
end

get '/create_memo' do
  File.open('num.txt', 'r') do |f|
    @id = f.read.to_i
  end
  erb :create_memo
end

post '/confirm/*' do
  File.open('num.txt', 'r') do |f|
    @id = f.read.to_i
  end
  Memo.create(id: @id, title: params[:title], content: params[:content])
  File.open('num.txt', 'w') do |f|
    f.print @id + 1
  end
  redirect to("/memo/#{@id}"), 303
end

get '/memo/*/edit' do
  @memo = Memo.read(session[:id])[0]
  erb :edit_memo
end

get '/memo/*' do
  session[:id] = params['splat'][0]
  @memo = Memo.read(session[:id])[0]
  erb :memo
end

patch '/confirm_edit/*' do
  session[:id] = params['splat'][0]
  @memo = Memo.read(session[:id])[0]
  Memo.edit(id: @memo['id'].to_i, title: params[:title], content: params[:content])
  redirect to("/memo/#{session[:id]}"), 303
end

not_found do
  '存在しないページにリクエストしています'
end
