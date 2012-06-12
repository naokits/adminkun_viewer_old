require 'rubygems'
require 'mechanize'
# require 'cgi'
require 'json'
require 'httpclient'

##############################################################################
# Create a channel
##############################################################################
baseurl = "http://localhost:4000"
url = baseurl + "/channels"
agent = WWW::Mechanize.new
page = agent.post(url)

# wait response
sleep 2

# receive id number
# data = JSON.parse(page.body)
# exit if data['id'].nil? 
# id = data['id']
id = 'cwyajq'
puts "id is #{id}"

##############################################################################
# Add subscribers
##############################################################################
# url = baseurl + "/subscribers"
# data = { :channelchannel => "#{id}", :url => "http://nkts.local:4567/watercoolr"
# }.to_json
# page = agent.post(url, :data => data)
# sleep 2
# status = JSON.parse(page.body)
# if status['status'] == "OK"
# else
#   puts "Occurse some problems. terminate this program..."
# end
# p status['status']


##############################################################################
# Post messages
##############################################################################
puts "Posting message"
url = baseurl + '/messages'
data = {:channel => "#{id}", "message" => "hello from watercoolr"}.to_json
page = agent.post(url, :data => data)
sleep 2; puts "waiting response..."
status = JSON.parse(page.body)
p status
