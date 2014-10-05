require 'rubygems'
require 'sinatra'
require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

class Note
  include DataMapper::Resource
  property :id, Serial
  property :content, Text, :required => true
  property :complete, Boolean, :required => true, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime 
end

DataMapper.finalize.auto_upgrade!

helpers do
  include Rack::Utils
  alias_method :h, :escape_html  
end

get '/' do
  @notes = Note.all :order => :id.desc
  @title = 'All Notes'
  erb :home
end

post '/' do
  n = Note.new
  n.content = params[:content]
  n.created_at = Time.now
  n.updated_at = Time.now
  n.save
  redirect '/'
end

get '/:id' do
  @note = Note.get(params[:id])
  @title = "Edit note #{params[:id]}"
  erb :edit 
end

put '/:id' do
  n = Note.get(params[:id])
  n.content = params[:content]
  n.complete = params[:complete] ? 1 : 0
  n.updated_at = Time.now
  n.save
  redirect "/"
end

get '/:id/complete' do
  n = Note.get params[:id]
  # toggle the complete status
  # n.complete = n.complete = !n.complete
  # the tutorial uses explicitly 0/1 instead of true false. 
  n.complete = n.complete ? 0 : 1
  n.updated_at = Time.now
  n.save
  redirect '/'
end

get '/:id/delete' do
  @note = Note.get(params[:id])
  @title = "Confirm deletion of note ##{params[:id]}"
  erb :delete
end

delete '/:id/delete' do
  n = Note.get(params[:id])
  n.destroy
  redirect '/'
end