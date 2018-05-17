require 'slack-ruby-bot'
require 'httparty'
require 'yaml'

class OpsBot < SlackRubyBot::Bot

	attr_accessor :oncall_primary, :oncall_secondary

	@config = YAML.load_file("config.yml")
	
	
	def self.post_on_call_message(client, chan)
			client.web_client.chat_postMessage(channel: "#{chan}", text: "#{@oncall_msg}")
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

    # 1. Incident
		command 'INC<#>' do
			desc 'Gives you a direct link to a ServiceNow Incident.'
			long_desc "I give you a direct link to a ServiceNow Incident so you can skip the time consuming \'copy, paste, search\' routine."
		end

		# 2. Reqeust
		command 'RITM<#>' do
			desc 'Gives you a direct link to a ServiceNow Request.'
			long_desc "I give you a direct link to a ServiceNow Request so you can skip the time consuming \'copy, paste, search\' routine."
		end

		 # 3. Problem
		 command 'PRB< #>' do
			desc 'Gives you a direct link to a ServiceNow Problem.'
			long_desc "I give you a direct link to a ServiceNow Problem so you can skip the time consuming \'copy, paste, search\' routine."
		end

    # 4. Outage
		command 'OUTG<#>' do
			desc 'Gives you a direct link to a ServiceNow Outage.'
			long_desc "I give you a direct link to a ServiceNow Outage so you can skip the time consuming \'copy, paste, search\' routine."
		end

    # 5. Change
		command 'CHG<#>' do
			desc 'Gives you a direct link to a ServiceNow Change.'
			long_desc "I give you a direct link to a ServiceNow Change so you can skip the time consuming \'copy, paste, search\' routine."
		end
    
    # 6. Project
		command 'PRJ<#>' do
			desc 'Gives you a direct link to a ServiceNow Project.'
			long_desc "I give you a direct link to a ServiceNow Project so you can skip the time consuming \'copy, paste, search\' routine."
		end

    # 7. Project Task
		command 'PRJTASK<#>' do
			desc 'Gives you a direct link to a ServiceNow Project Task.'
			long_desc "I give you a direct link to a ServiceNow Project Task so you can skip the time consuming \'copy, paste, search\' routine."
		end

    # 8. Operational Task
		command 'WTSK<#>' do
			desc 'Gives you a direct link to a ServiceNow Operational Task.'
			long_desc "I give you a direct link to a ServiceNow Operational Task so you can skip the time consuming \'copy, paste, search\' routine."
		end

    # 9. Demand/Project Request
		command 'DMND<#>' do
			desc 'Gives you a direct link to a ServiceNow Demand.'
			long_desc "I give you a direct link to a ServiceNow Demand so you can skip the time consuming \'copy, paste, search\' routine."
		end

    # 10. Requirement
		command 'DREQ<#>' do
			desc 'Gives you a direct link to a ServiceNow Requirement.'
			long_desc "I give you a direct link to a ServiceNow Requirement so you can skip the time consuming \'copy, paste, search\' routine."
		end

    # 11. Release Task
		command 'RTASK<#>' do
			desc 'Gives you a direct link to a ServiceNow Release Task.'
			long_desc "I give you a direct link to a ServiceNow Release Task so you can skip the time consuming \'copy, paste, search\' routine."
		end

		command 'Who\'s on call this weekend?' do
			desc 'Tells you who is on call this weekend.'
		end
	end

	# 1. Incident
	SN_INC_BASE_URL="https://wcmcprd.service-now.com/nav_to.do?uri=incident.do?sysparm_query=number="
	
	# 2. Reqeust
	SN_RITM_BASE_URL="https://wcmcprd.service-now.com/nav_to.do?uri=sc_req_item.do?sysparm_query=number="

	# 3. Problem
	SN_PRB_BASE_URL="https://wcmcprd.service-now.com/nav_to.do?uri=problem.do?sysparm_query=number="

  # 4. Outage
  SN_OUTG_BASE_URL="https://wcmcprd.service-now.com/nav_to.do?uri=cmdb_ci_outage.do?sysparm_query=number="

  # 5. Change
  SN_CHG_BASE_URL="https://wcmcprd.service-now.com/nav_to.do?uri=change_request.do?sysparm_query=number="

  # 6. Project
  SN_PRJ_BASE_URL="https://wcmcprd.service-now.com/nav_to.do?uri=pm_project.do?sysparm_query=number="

  # 7. Project Task
  SN_PRJTASK_BASE_URL="https://wcmcprd.service-now.com/nav_to.do?uri=pm_project_task.do?sysparm_query=number="

  # 8. Operational Task
	SN_WTASK_BASE_URL="https://wcmcprd.service-now.com/nav_to.do?uri=u_its_planned_task.do?sysparm_query=number="

  # 9. Demand, aka, Project Request
	SN_DMND_BASE_URL="https://wcmcprd.service-now.com/nav_to.do?uri=dmn_demand.do?sysparm_query=number="

  # 10. Requirement
	SN_DREQ_BASE_URL="https://wcmcprd.service-now.com/nav_to.do?uri=dmn_requirement.do?sysparm_query=number="
  
  # 11. Release Task
	SN_RTASK_BASE_URL="https://wcmcprd.service-now.com/nav_to.do?uri=rm_task.do?sysparm_query=number="

	command 'ping' do |client, data, match|
		client.say(text: 'pong', channel: data.channel)
	end

	# 1. Incident
	scan (/\bINC\d{7}\b/i) do |client, data, match|
		match.each do |m|
			client.web_client.chat_postMessage(channel: data.channel, as_user: true, text: "Here's a direct link: <#{SN_INC_BASE_URL}#{m} | #{m}>")
		end
	end

	# 2. Request
	scan (/\bRITM\d{7}\b/i) do |client, data, match|
		match.each do |m|
			client.web_client.chat_postMessage(channel: data.channel, as_user: true, text: "Here's a directink: <#{SN_RITM_BASE_URL}#{m} | #{m}>")
		end
	end

	# 3. Problem
	scan (/\bPRB\d{7}\b/i) do |client, data, match|
		match.each do |m|
			client.web_client.chat_postMessage(channel: data.channel, as_user: true, text: "Here's a directink: <#{SN_PRB_BASE_URL}#{m} | #{m}>")
		end
	end

  # 4. Outage
	scan (/\bOUTG\d{7}\b/i) do |client, data, match|
		match.each do |m|
			client.web_client.chat_postMessage(channel: data.channel, as_user: true, text: "Here's a directink: <#{SN_OUTG_BASE_URL}#{m} | #{m}>")
		end
	end

  # 5. Change
	scan (/\bCHG\d{7}\b/i) do |client, data, match|
		match.each do |m|
			client.web_client.chat_postMessage(channel: data.channel, as_user: true, text: "Here's a directink: <#{SN_CHG_BASE_URL}#{m} | #{m}>")
		end
	end

  # 6. Project
	scan (/\bPRJ\d{7}\b/i) do |client, data, match|
		match.each do |m|
			client.web_client.chat_postMessage(channel: data.channel, as_user: true, text: "Here's a directink: <#{SN_PRJ_BASE_URL}#{m} | #{m}>")
		end
	end

  # 7. Project Task
	scan (/\bPRJTASK\d{7}\b/i) do |client, data, match|
		match.each do |m|
			client.web_client.chat_postMessage(channel: data.channel, as_user: true, text: "Here's a directink: <#{SN_PRJTASK_BASE_URL}#{m} | #{m}>")
		end
	end

  # 8. Operational Task
	scan (/\bWTASK\d{7}\b/i) do |client, data, match|
		match.each do |m|
			client.web_client.chat_postMessage(channel: data.channel, as_user: true, text: "Here's a directink: <#{SN_WTASK_BASE_URL}#{m} | #{m}>")
		end
	end

  # 9. Demand, aka, Project Request
	scan (/\bDMND\d{7}\b/i) do |client, data, match|
		match.each do |m|
			client.web_client.chat_postMessage(channel: data.channel, as_user: true, text: "Here's a directink: <#{SN_DMND_BASE_URL}#{m} | #{m}>")
		end
	end

  # 10. Requirement
	scan (/\bDREQ\d{7}\b/i) do |client, data, match|
		match.each do |m|
			client.web_client.chat_postMessage(channel: data.channel, as_user: true, text: "Here's a directink: <#{SN_DREQ_BASE_URL}#{m} | #{m}>")
		end
	end

  # 11. Release Task
	scan (/\bRTASK\d{7}\b/i) do |client, data, match|
		match.each do |m|
			client.web_client.chat_postMessage(channel: data.channel, as_user: true, text: "Here's a directink: <#{SN_RTASK_BASE_URL}#{m} | #{m}>")
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
