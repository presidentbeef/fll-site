require "rubygems"
require "sinatra"
require "datamapper"
require "sinatra/captcha"
require "sinatra-authentication"

use Rack::Session::Cookie, :secret => 'aisdhasd8!*@*@08ashda8sdhklxbcv8web9qwoooo'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/langs.db")

class Languages
	include DataMapper::Resource

	property :name, Text, :key => true
	property :display_name, Text
	property :summary, Text
	property :url, Text
	property :date_added, Date
	property :last_modified, DateTime
	property :moderated, Boolean, :default => false
	property :blurb, Text
	property :blurb_html, Text
	property :author, Text

	def self.approved
		all(:moderated => true, :order => [:name.asc])
	end

	def self.unapproved
		all(:moderated => false, :order => [:name.asc])
	end	
end

Languages.auto_upgrade!

helpers do
	def make_lang params, name, display_name
		require 'cgi'
		require 'bluecloth'
		bluecloth_opts = {:remove_images => true, :escape_html => true, :auto_links => true }
		Languages.new :name => CGI.escapeHTML(name),
			:display_name => CGI.escapeHTML(display_name),
			:summary => CGI.escapeHTML(params[:lang_summary]),
			:url => CGI.escapeHTML(params[:lang_url]),
			:blurb => CGI.escapeHTML(params[:lang_blurb]),
			:blurb_html => BlueCloth.new(params[:lang_blurb]).to_html,
			:author => CGI.escapeHTML(params[:lang_author] || ""),
			:date_added => Date.today,
			:moderated => false
	end
end

['/', '/langs/?'].each do |path|
	get path  do
		@approved_langs = Languages.approved
		@unapproved_langs = Languages.unapproved
		erb :index
	end
end

get '/langs/:name/?' do
	@lang = Languages.get(params[:name].downcase)
	if @lang.nil?
		@lang = params[:name].downcase
		erb :no_lang
	else
		last_modified @lang.last_modified
		erb :show_lang
	end
end

get '/submit/?' do
	@params = params
	erb :submit
end

post '/submit' do
	display_name = params[:lang_name]
	name = display_name.downcase.gsub(" ", "_")
	$stderr.puts params.inspect

	if captcha_pass?
		if Languages.get(name)
			@display_name = display_name
			@name = name
			erb :exists
		else
			@lang = make_lang params, name, display_name 

			if @lang.save
				redirect "/langs/#{name}/", 302
			else
				"Failed to save #{display_name}"
			end
		end
	else
		@params = params
		erb :submit
	end
end

post '/preview' do	
	display_name = params[:lang_name]
	name = display_name.downcase.gsub(" ", "_")
	@lang = make_lang params, name, display_name

	erb :show_lang
end
