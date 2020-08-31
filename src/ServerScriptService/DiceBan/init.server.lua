--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: A ban system utilizing messaging service & datastores with a command bar
--]]

--// logic
local Verified = {29806839,46522586}

--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
	cache[serviceName] = game:GetService(serviceName)
	return cache[serviceName]
end})

--// variables
local MsgService = require(script.Modules.DiceMsgService)
local QuickStore = require(script.Modules.DiceQuickStore)

local Network = script.DiceRemotes
local banFunc = Network.banFunc
Network.Parent = Services['ReplicatedStorage']

local BanUI = script.BanUI

--// functions
QuickStore:SetData('ban',{
	['Bans'] = {};
})

local function GetPlayer(compareText,userID)
	if userID and tonumber(compareText) then
		if Services['Players']:GetNameFromUserIdAsync(compareText) then
			return tonumber(compareText)
		end
	end
	if tonumber(compareText) and not userID then
		local getPlr = Services['Players']:GetPlayerByUserId(compareText)
		if getPlr then
			return getPlr
		end
	end
	local closestTable = {
		['User'] = '';
		['Count'] = 0;
	}
	for Index,Compare in pairs(Services['Players']:GetPlayers()) do
		local compareName = string.match(string.lower(Compare.Name),string.lower(compareText))
		if compareName then
			if #compareName > closestTable['Count'] then
				closestTable['User'] = Compare
				closestTable['Count'] = #compareName
			end
		end
	end
    if closestTable['Count'] == 0 and closestTable['User'] == '' then
		return false
	else
		if userID then
			return closestTable['User'].UserId
		else
			return closestTable['User']
		end
	end
end

local function BanPlayer(userID)
	local findPlr = GetPlayer(userID,false)
	if findPlr then
		findPlr:Kick('\nBanned')
		return
	end
	MsgService:FireEvent('plrSearch',userID)
end

local function PackArgs(message)
	local argCount = 0
	local cmdArgs = {}
	for index in string.gmatch(message,'%w+') do
		argCount = argCount + 1
		cmdArgs[argCount] = index
	end
	return cmdArgs
end

MsgService:ConnectKey('plrSearch',function(message)
	if tonumber(message) then
		BanPlayer(message)
		return true
	end
end)

local Commands = {
	['ban'] = function(userID)
		local Load = QuickStore:LoadData('Bans')
		if Load then
			if not table.find(Load,userID) then
				table.insert(Load,userID)
				local Save = QuickStore:SaveData('Bans',Load)
				if Save then
					BanPlayer(userID)
					return '✅ Success: Banned UserId '..userID
				end
				return '❌ Failed: Could not save data'
			end
		end
		return '❌ Failed: Could not load data'
	end;
	
	['unban'] = function(userID)
		local Load = QuickStore:LoadData('Bans')
		if Load then
			if table.find(Load,userID) then
				table.remove(Load,table.find(Load,userID))
				local Save = QuickStore:SaveData('Bans',Load)
				if Save then
					return '✅ Success: Unbanned UserId '..userID
				end
				return '❌ Failed: Could not save data'
			end
		end
		return '❌ Failed: Could not load data'
	end;
}

banFunc.OnServerInvoke = function(plr,message)
	if not table.find(Verified,plr.UserId) then plr:Kick('Exploit attempted') return end
	local value = string.lower(message)
	for index,cmd in pairs(Commands) do
		if string.sub(value,1,#index) == index then
			local getArgs = PackArgs(string.sub(message,#index + 1))
			local getUserId = GetPlayer(getArgs[1],true)
			local results = cmd(getUserId)
			return results
		end
	end
	return '❌ Failed: '..message
end

Services['Players'].PlayerAdded:Connect(function(Plr)
	local getBans = QuickStore:LoadData('Bans')
	if table.find(getBans,Plr.UserId) and not Services['RunService']:IsStudio() and not table.find(Verified,Plr.UserId) then
		Plr:Kick('\nBanned')
		return
	end
	if table.find(Verified,Plr.UserId) then
		local PlayerGui = Plr:FindFirstChild('PlayerGui') or Plr:WaitForChild('PlayerGui')
		local cloneUI = BanUI:Clone()
		cloneUI.Parent = PlayerGui
		cloneUI.BanClient.Disabled = false
	end
end)