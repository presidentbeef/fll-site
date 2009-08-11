require "rubygems"
require "datamapper"
require "/usr/lib/ruby/gems/1.8/gems/sinatra-authentication-0.0.2/lib/models/user"
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/langs.db")
User.auto_upgrade!

u = User.all(:email => "presidentbeef")

if not u.empty?
	p u	
	abort "Already there!"
end

u = User.new(:email => "presidentbeef", :password => "pinoforks!!", :password_confirmation => "pinoforks!!", :created_at => DateTime.now )
p u
if u.save!
	puts "Yep"
else
p u
	puts "nope"
end
