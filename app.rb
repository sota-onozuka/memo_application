# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'fileutils'

enable :method_override
use Rack::Session::Cookie

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  erb :index
end

delete '/memo/:id/delete' do
  @memos = JSON.parse(open('memos.json').read)
  @memos['memos'] = @memos['memos'].reject { |m| m['id'].to_i == params[:id].to_i }
  File.open('memos.json', 'w') do |f|
    JSON.dump(@memos, f)
  end
  redirect to('/'), 303
end

get '/create_memo' do
  File.open('num.txt', 'r') do |f|
    @id = f.read.to_i
  end
  erb :create_memo
end

post '/confirm' do
  File.open('num.txt', 'r') do |f|
    @id = f.read.to_i
  end
  @memos = JSON.parse(open('memos.json').read)
  memo = { 'id' => @id, 'title' => params[:title], 'body' => params[:content] }
  @memos['memos'].push(memo)
  File.open('memos.json', 'w') do |f|
    JSON.dump(@memos, f)
  end
  File.open('num.txt', 'w') do |f|
    f.print @id + 1
  end
  redirect to("/memo/#{@id}"), 303
end

get '/memo/:id/edit' do
  @id = params[:id]
  erb :edit_memo
end

get '/memo/:id' do
  @id = params[:id]
  erb :memo
end

patch '/confirm_edit/:id' do
  @memos = JSON.parse(open('memos.json').read)
  @memos['memos'].each do |memo|
    next unless memo['id'].to_i == params[:id].to_i

    memo['title'] = params[:title]
    memo['body'] = params[:content]
    File.open('memos.json', 'w') do |f|
      JSON.dump(@memos, f)
    end
  end
  redirect to("/memo/#{params[:id]}"), 303
end
