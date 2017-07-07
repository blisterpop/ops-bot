require 'slack-ruby-bot'
require 'httparty'

class OpsBot < SlackRubyBot::Bot

	@oncall_msg = "OPS On-Call:\n
Primary - Carlos Castilla
cac2055@med.cornell.edu
Cell 646-939-0078
---
Secondary - Danny Tan
gut2001@med.cornell.edu
Home 718-265-0869
Cell 347-236-6019
\n"

	def self.post_on_call_message(client, chan)
			client.web_client.chat_postMessage(channel: "#{chan}", text: "#{@oncall_msg}")
	end

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
		match.each do |m|
			client.web_client.chat_postMessage(channel: data.channel, as_user: true, text: "Here's a direct link: <#{SN_INC_BASE_URL}#{m} | #{m}>")
		end
	end

	scan (/\bRITM\d{7}\b/i) do |client, data, match|
		match.each do |m|
			client.web_client.chat_postMessage(channel: data.channel, as_user: true, text: "Here's a directink: <#{SN_RITM_BASE_URL}#{m} | #{m}>")
		end
	end

	match /on call/i do |client, data, match|
		post_on_call_message(client, data.channel)
	end

	match /^\!admin.*/ do |client,data,match|
		commands = data["text"].split(" ")

		if commands[1] == "announce"
			client.web_client.chat_postMessage(channel: '#ops-sys', text: "I'm Baaack")
		elsif commands[1] == "oncall"
			if commands[2] == "here"
				post_on_call_message(client, data.channel)
			else
				post_on_call_message(client, commands[2])
			end
		else
			client.say(channel: data.channel, text: "Unknown Admin Command")
		end
	end

	

end


SlackRubyBot::Client.logger.level = Logger::WARN

OpsBot.run
