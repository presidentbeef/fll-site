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

BlueCloth_Opts = {:remove_images => true, :escape_html => true, :auto_links => true }

helpers do
	def make_lang params, name, display_name
		require 'cgi'
		require 'bluecloth'
		Languages.new :name => name,
			:display_name => CGI.escapeHTML(display_name),
			:summary => CGI.escapeHTML(params[:lang_summary]),
			:url => CGI.escapeHTML(params[:lang_url]),
			:blurb => CGI.escapeHTML(params[:lang_blurb]),
			:blurb_html => BlueCloth.new(params[:lang_blurb], BlueCloth_Opts).to_html,
			:author => CGI.escapeHTML(params[:lang_author] || ""),
			:date_added => Date.today,
			:last_modified => DateTime.now,
			:moderated => false
	end
end

get '/' do
	latest = Languages.all(:order => [:last_modified.desc]).first
	if latest
		last_modified(latest.last_modified || DateTime.now)
	end

	@approved_langs = Languages.approved
	@unapproved_langs = Languages.unapproved
	erb :index
end

get '/lang/:name/?' do
	@lang = Languages.get(params[:name])
	if @lang.nil?
		@lang = params[:name]
		erb :no_lang
	else
		last_modified(@lang.last_modified || DateTime.now)
		erb :show_lang
	end
end

get '/feedback/?' do
	erb :feedback
end

get '/criteria/?' do
	erb :criteria
end

get '/submit/?' do
	@params = params
	erb :submit
end

post '/submit' do
	display_name = params[:lang_name]
	name = display_name.downcase.gsub(/[^a-zA-Z0-9]/, "_")

	if captcha_pass?
		if Languages.get(name)
			@display_name = display_name
			@name = name
			erb :exists
		else
			@lang = make_lang params, name, display_name 

			if @lang.save
				redirect "/lang/#{@lang.name}/", 302
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
	name = display_name.downcase.gsub(/[^a-zA-Z0-9]/, "_")
	@lang = make_lang params, name, display_name
	@preview = true

	erb :show_lang
end

get '/admin' do
	login_required

	@langs = Languages.all
	erb :admin
end

get '/admin/delete/:name' do
	login_required

	lang = Languages.get(params[:name])
	lang.destroy unless lang.nil?

	redirect '/admin'
end

get '/admin/edit/:name' do
	login_required

	lang = Languages.get(params[:name])

	@params = {}
	@params[:lang_name] = lang.display_name
	@params[:lang_url] = lang.url
	@params[:lang_summary] = lang.summary
	@params[:lang_blurb] = lang.blurb
	@params[:lang_author] = lang.author
	erb :edit
end

post '/admin/edit' do
	login_required
	
	require 'cgi'
	require 'bluecloth'

	display_name = params[:lang_name]
	name = display_name.downcase.gsub(" ", "_")
	lang = Languages.get(name)
	lang.display_name = CGI.escapeHTML(display_name)
	lang.summary = CGI.escapeHTML(params[:lang_summary])
	lang.url = CGI.escapeHTML(params[:lang_url])
	lang.blurb = CGI.escapeHTML(params[:lang_blurb])
	lang.blurb_html = BlueCloth.new(params[:lang_blurb], BlueCloth_Opts).to_html
	lang.author = CGI.escapeHTML(params[:lang_author] || "")
	lang.last_modified = DateTime.now

	if lang.update
		redirect '/admin'
	else
		"Bad..."
	end
end

get '/admin/approve/:name' do
	login_required

	lang = Languages.get(params[:name])

	if lang.nil?
		"No such language."
	else
		lang.moderated = true
		lang.last_modified = DateTime.now

		if lang.update
			redirect '/admin'
		else
			"Could not update."
		end
	end
end


