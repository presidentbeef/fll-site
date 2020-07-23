require "rubygems"
require "sinatra"
require "datamapper"
require "net/http"
require "uri"

use Rack::Session::Cookie, :secret => 'dum dum dum'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/langs.db")

class Languages
	include DataMapper::Resource

	property :name, Text, :key => true
	property :display_name, Text
	property :summary, Text
	property :url, Text
  property :source_url, Text
  property :try_url, Text
	property :date_added, Date
	property :last_modified, DateTime
	property :moderated, Boolean, :default => false
	property :blurb, Text
	property :blurb_html, Text
	property :example, Text
	property :author, Text
	property :inactive, Boolean, :default => false
  property :retired, Boolean, :default => false

	def self.approved
		all(:moderated => true, :inactive => false, :order => [:name.asc])
	end

	def self.unapproved
		all(:moderated => false, :order => [:name.asc])
	end	
	
	def self.inactive
		all(:inactive => true, :retired => false, :order => [:name.asc])
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
      :example => CGI.escapeHTML(params[:lang_example].strip),
			:author => CGI.escapeHTML(params[:lang_author] || ""),
			:date_added => Date.today,
			:last_modified => DateTime.now,
			:moderated => false
	end

  def login_required
    if session[:admin] != "you know what"
      redirect "/"
    end
  end
end

get '/' do
	latest = Languages.all(:order => [:last_modified.desc]).first
	if latest
		last_modified(latest.last_modified || DateTime.now)
	end

	@approved_langs = Languages.approved
	@unapproved_langs = Languages.unapproved
	@inactive_langs = Languages.inactive
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

def captcha_pass? response
  opts = { "secret" => "blahdyblah",
           "response" => response }

  verify_check= Net::HTTP.post_form(URI("https://www.google.com/recaptcha/api/siteverify"), opts)

  if verify_check
    verified = JSON.parse(verify_check.body)
    if verified["success"]
      return true
    else
      $stderr.puts verified.inspect
      return false
    end
  end
end

post '/submit' do
	display_name = params[:lang_name]
	name = display_name.downcase.gsub(/[^a-zA-Z0-9]/, "_")

	if captcha_pass? params[:'g-recaptcha-response']
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

get '/admin/login' do
	erb :login
end

post '/admin/login' do
  if captcha_pass? params[:'g-recaptcha-response']
    if params[:user] == "whaaaaa?" and params[:pass] == "woohoo"
      session[:admin] = "hmmmhmm"
      redirect '/admin'
    else
      redirect '/'
    end
  else
    redirect '/'
  end
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
	@params[:source_url] = lang.source_url
	@params[:try_url] = lang.try_url
	@params[:lang_summary] = lang.summary
	@params[:lang_blurb] = lang.blurb
	@params[:lang_example] = lang.example
	@params[:lang_author] = lang.author
	erb :edit
end

post '/admin/edit' do
	login_required
	
	require 'cgi'
	require 'bluecloth'

	display_name = params[:lang_name]
	name = display_name.downcase.gsub(/[^a-zA-Z0-9]/, "_")
  lang = Languages.get(name)
  lang.display_name = CGI.escapeHTML(display_name)
	lang.summary = CGI.escapeHTML(params[:lang_summary])
	lang.url = CGI.escapeHTML(params[:lang_url])
	lang.try_url = CGI.escapeHTML(params[:try_url])
	lang.source_url = CGI.escapeHTML(params[:source_url])
	lang.blurb = CGI.escapeHTML(params[:lang_blurb])
	lang.blurb_html = BlueCloth.new(params[:lang_blurb], BlueCloth_Opts).to_html
	lang.example = CGI.escapeHTML(params[:lang_example].strip)
	lang.author = CGI.escapeHTML(params[:lang_author] || "")
	lang.last_modified = DateTime.now

	if lang.save
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

		if lang.save
			redirect '/admin'
		else
			"Could not update."
		end
	end
end

get '/admin/active/:name' do
	login_required

	lang = Languages.get(params[:name])

	if lang.nil?
		"No such language."
	else
		lang.inactive = false
		lang.last_modified = DateTime.now

		if lang.save
			redirect '/admin'
		else
			"Could not update."
		end
	end
end

get '/admin/inactive/:name' do
	login_required

	lang = Languages.get(params[:name])

	if lang.nil?
		"No such language."
	else
		lang.inactive = true
		lang.last_modified = DateTime.now

		if lang.save
			redirect '/admin'
		else
			"Could not update."
		end
	end
end
