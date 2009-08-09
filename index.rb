require "rubygems"
require "sinatra"
require "datamapper"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/langs.db")

class Language
	include DataMapper::Resource

	property :name, Text, :key => true
	property :display_name, Text
	property :summary, Text
	property :url, Text
	property :date_added, Date
	property :moderated, Boolean, :default => false
	property :blurb, Text
	property :author, Text
end

Language.auto_upgrade!

['/', '/langs/?'].each do |path|
	get path  do
		@langs = Language.all(:order => [:name.asc])
		erb :list
	end
end

get '/langs/:name/?' do
	@lang = Language.get(params[:name].downcase)
	if @lang.nil?
		@lang = params[:name].downcase
		erb :no_lang
	else
		erb :show_lang
	end
end

get '/submit/?' do
	erb :submit
end

post '/submit/?' do
	display_name = params[:lang_name]
	name = display_name.downcase.gsub(" ", "_")
	$stderr.puts params.inspect
	if Language.get(name)
		@display_name = name
		@name = name
		erb :exists
	else
		require 'cgi'
		@lang = Language.new :name => CGI.escapeHTML(name),
			:display_name => CGI.escapeHTML(display_name),
			:summary => CGI.escapeHTML(params[:lang_summary]),
			:url => CGI.escapeHTML(params[:lang_url]),
			:blurb => CGI.escapeHTML(params[:lang_blurb]),
			:author => CGI.escapeHTML(params[:lang_author] || ""),
			:date_added => Date.today,
			:moderated => false

		$stderr.puts @lang.inspect

		if @lang.save
			redirect "/langs/#{name}/", 302
		else
			"Failed to save #{display_name}"
		end
	end
end

get '/deleteall/' do
	Language.all.destroy!
end
