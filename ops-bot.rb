require 'slack-ruby-bot'
require 'httparty'

class OpsBot < SlackRubyBot::Bot

	SN_INC_BASE_URL="https://wcmcprd.service-now.com/nav_to.do?uri=incident.do?sysparm_query=number="
	SN_RITM_BASE_URL="https://wcmcprd.service-now.com/nav_to.do?uri=sc_req_item.do?sysparm_query=number="

	command 'oncall' do |client, data, match|
		
	end

	command 'ping' do |client, data, match|
		client.say(text: 'pong', channel: data.channel)
	end

	scan (/\bINC\d{7}\b/i) do |client, data, match|
		client.say(channel: data.channel, text: "Hey that looks like a Service Now Incident!\nHere's a helpful link: ")
		match.each do |m|
			client.web_client.chat_postMessage(channel: data.channel, as_user: true, text: "<#{SN_INC_BASE_URL}#{m} | #{m}>")
		end
	end

	scan (/\bRITM\d{7}\b/i) do |client, data, match|
		client.say(channel: data.channel, text: "Hey that looks like a Service Now Request!\nHere's a helpful link: ")
		match.each do |m|
			client.web_client.chat_postMessage(channel: data.channel, as_user: true, text: "<#{SN_RITM_BASE_URL}#{m} | #{m}>")
		end
	end

	match /(on\scall|oncall)/ do |client, data, match|
		client.say(channel: data.channel, text: "@carlos is on call this weekend!")
	end


end


SlackRubyBot::Client.logger.level = Logger::WARN

OpsBot.run