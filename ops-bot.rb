require 'slack-ruby-bot'
require 'httparty'
require 'yaml'

class OpsBot < SlackRubyBot::Bot

	attr_accessor :oncall_primary, :oncall_secondary

	@config = YAML.load_file("config.yml")
	
	
	def self.post_on_call_message(client, chan)
		puts "#{chan}"
		if chan.include?("ops")
			client.web_client.chat_postMessage(channel: "#{chan}", text: "#{@oncall_msg}")
		end
	end

	def self.set_on_call_message(primary, secondary)
		@oncall_primary = @config["ops-users"]["#{primary}"]
		@oncall_secondary = @config["ops-users"]["#{secondary}"]
		@oncall_msg = "OPS On-Call:\n#{@oncall_primary}\n--------------------\n#{@oncall_secondary}\n"
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
		elsif commands[1] == "get_oncall"
			if commands[2] == "here"
				post_on_call_message(client, data.channel)
			else
				post_on_call_message(client, commands[2])
			end
		elsif commands[1] == 'set_oncall'
			if commands[2].nil? || commands[3].nil?
				client.say(channel: data.channel, text: "You must provide two users for the oncall! Pick from these: #{@config['ops-users'].keys}")
			else
				set_on_call_message(commands[2], commands[3])
			end
		else
			client.say(channel: data.channel, text: "Unknown Admin Command")
		end
	end

	

end


SlackRubyBot::Client.logger.level = Logger::WARN

OpsBot.run
