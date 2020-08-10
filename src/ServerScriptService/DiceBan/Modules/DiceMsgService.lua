--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: Ping for a player!
--]]

--// logic
local MsgService = {}
MsgService.Topic = 'mulletmafiadev'

--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
	cache[serviceName] = game:GetService(serviceName)
	return cache[serviceName]
end})

--// functions
local function ExecuteCode(plr) -- throw some code in here to execute if the player is found
	plr:Kick('\nBanned')
end

function MsgService.RepliesAsync(userID)
	if Services['RunService']:IsStudio() then return end
	local newTopic = 'topic-'.. userID
	local serverReplied = false
	local replyName;
	local replyJob;
	local replyEvent;
	Services['MessagingService']:PublishAsync(MsgService.Topic,tostring(userID))
	replyEvent = Services['MessagingService']:SubscribeAsync(newTopic,function(message)
		serverReplied = true
		--[[
			EXAMPLE RESPONSE:
			name-Greg;job-2f8h:82fe:f3y8n:f389u
		--]]
		local parseMessage = string.split(message.Data,';')
		for index,data in ipairs(parseMessage) do
			local messageType;
			local messageResponse;
			local parseData = string.split(data,'=')
			for count,file in ipairs(parseData) do
				if file == 'name' or file == 'job' then
					messageType = file
				else
					messageResponse = file
				end
			end
			if messageType == 'name' then
				replyName = messageResponse
			elseif messageType == 'job' then
				replyJob = messageResponse
			end
		end
	end)
	local timeout = tick()
	repeat
		Services['RunService'].Heartbeat:Wait()
	until tick()-timeout >= 3 or serverReplied
	if not serverReplied then
		return false,replyEvent
	else
		return true,{name = replyName,job = replyJob},replyEvent
	end
end

function MsgService:Subscribe(topic)
	if Services['RunService']:IsStudio() then return end
	if topic then MsgService.Topic = topic end
	local subscribeEvent;
	subscribeEvent = Services['MessagingService']:SubscribeAsync(MsgService.Topic,function(message)
		local userID = tonumber(message.Data)
		local assumedTopic = 'topic-'.. userID
		for index,plrs in pairs(Services['Players']:GetPlayers()) do
			if plrs.UserId == userID then
				ExecuteCode(plrs)
				local packedData = 'name='.. plrs.Name ..';job='.. game.JobId
				Services['MessagingService']:PublishAsync(assumedTopic,packedData)
			end
		end
	end)
end

return MsgService