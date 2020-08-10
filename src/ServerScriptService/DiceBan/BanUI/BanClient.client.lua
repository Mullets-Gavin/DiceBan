--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
	cache[serviceName] = game:GetService(serviceName)
	return cache[serviceName]
end})

--// variables
local globalInfo = TweenInfo.new(0.4)

local Showcase = script:WaitForChild('Showcase')
local Toggle = script.Parent:WaitForChild('Toggle')
local Notifications = script.Parent:WaitForChild('Notifications')
local Contents = script.Parent:WaitForChild('Contents')

local Network = Services['ReplicatedStorage']:WaitForChild('DiceRemotes')
local banFunc = Network.banFunc

--// functions
local function CreateFeed(message)
	local newNotif = Showcase:Clone()
	newNotif.Parent = Notifications
	newNotif.Title.Text = message
	newNotif.Visible = true
	local tweenUp = Services['TweenService']:Create(newNotif,globalInfo,{Size = UDim2.new(1, 0, 1, 0)})
	tweenUp:Play()
	tweenUp.Completed:Wait()
	local tweenWhite = Services['TweenService']:Create(newNotif.Fancy,globalInfo,{BackgroundTransparency = 1})
	tweenWhite:Play()
	wait(7)
	for index,obj in pairs(newNotif:GetDescendants()) do
		if obj:IsA('TextLabel') then
			local tweenGone = Services['TweenService']:Create(obj,globalInfo,{TextTransparency = 1})
			tweenGone:Play()
		elseif obj:IsA('Frame') then
			local tweenGone = Services['TweenService']:Create(obj,globalInfo,{BackgroundTransparency = 1})
			tweenGone:Play()
		end
	end
	local tweenBack = Services['TweenService']:Create(newNotif,globalInfo,{BackgroundTransparency = 1})
	tweenBack:Play()
	tweenBack.Completed:Wait()
	newNotif:Destroy()
end

local function OpenCommandBar()
	Contents.Message.Text = ''
	local tweenIn = Services['TweenService']:Create(Contents,globalInfo,{Position = UDim2.new(0.5, 0, 0.5, 0)})
	tweenIn:Play()
	tweenIn.Completed:Wait()
	Contents.Message:CaptureFocus()
end

local function CloseCommandBar()
	local tweenOut = Services['TweenService']:Create(Contents,globalInfo,{Position = UDim2.new(0.5, 0, 1.5, 0)})
	tweenOut:Play()
end

Services['UserInputService'].InputBegan:Connect(function(input,processed)
	if not processed then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.BackSlash then
				OpenCommandBar()
			end
		end
	end
end)

Toggle.Button.MouseEnter:Connect(function()
	Toggle.Cover.ImageTransparency = 0.9
end)
Toggle.Button.MouseLeave:Connect(function()
	Toggle.Cover.ImageTransparency = 1
end)
Toggle.Button.MouseButton1Click:Connect(function()
	OpenCommandBar()
end)

Contents.Message.FocusLost:Connect(function()
	local message = Contents.Message.Text
	if message ~= '' and message ~= ' ' then
		Contents.Message.Text = 'Waiting for response...'
		local results = banFunc:InvokeServer(message)
		CloseCommandBar()
		CreateFeed(results)
	else
		CloseCommandBar()
	end
end)