require 'slack-ruby-bot'
require 'httparty'

class OpsBot < SlackRubyBot::Bot

	@oncall_user = "Carlos is on call, Danny is backup"

	SlackRubyBot.configure do |config|
		config.aliases = ['opsbot', 'OpsBot', 'ops bot']
		config.send_gifs = false
	end

	help do
		title 'Ops Bot'
		desc 'This bot enhances our operations capabilities.'

		command 'INC<#>' do
			desc 'Gives you a direct link to a ServiceNow Incident.'
			long_desc "I give you a direct link to a ServiceNow Incident so you can skip the time consuming \'copy, paste, search\' routine."
		end

		command 'RITM<#>' do
			desc 'Gives you a direct link to a ServiceNow Request.'
			long_desc "I give you a direct link to a ServiceNow Request so you can skip the time consuming \'copy, paste, search\' routine."
		end

		command 'Who\'s on call this weekend?' do
			desc 'Tells you who is on call this weekend.'
		end
	end


	SN_INC_BASE_URL="https://wcmcprd.service-now.com/nav_to.do?uri=incident.do?sysparm_query=number="
	SN_RITM_BASE_URL="https://wcmcprd.service-now.com/nav_to.do?uri=sc_req_item.do?sysparm_query=number="


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

	match /on call/i do |client, data, match|
		if @oncall_user == ""
			client.say(channel: data.channel, text: "No one is on call!!!")
		else
			client.say(channel: data.channel, text: "#{@oncall_user} is on call this weekend!")
		end
	end

	match /i\'m on call/i do |client, data, match|
		@oncall_user = data['user']['id']
		client.say(channel: data.channel, text: "#{@oncall_user} is now the user on call!")
	end

	match /\!admin.*/ do |client,data,match|
		commands = data["text"].split(" ")

		if commands[1] == "announce"
			client.web_client.chat_postMessage(channel: '#ops-bot-testing', text: "I'm Baaack")
		else
			client.say(channel: data.channel, text: "Unknown Admin Command")
		end
	end

end


SlackRubyBot::Client.logger.level = Logger::WARN

OpsBot.run