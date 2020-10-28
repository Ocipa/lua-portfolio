--K.E. (Ocipa), October 2020

local players = game.Players
local player = players.LocalPlayer

local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui", playerGui)

local hotbarImage = "rbxassetid://3253722905"

local slotSize = 50
local tweenTime = 0.1
local padding = 8

local hotbar = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {},
	[6] = {}
}
local currentSelected = nil

local frame = Instance.new("Frame", screenGui)
frame.AnchorPoint = Vector2.new(0.5, 1)
frame.Size = UDim2.new(0, slotSize, 0, slotSize)
frame.Position = UDim2.new(0.5, 0, 1, -15)
frame.BackgroundTransparency = 1

local list = Instance.new("UIListLayout", frame)
list.FillDirection = Enum.FillDirection.Horizontal
list.Padding = UDim.new(0, padding)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.SortOrder = Enum.SortOrder.Name


for i, v in pairs(hotbar) do
	local stringNum = "000"
	
	local button = Instance.new("ImageButton", frame)
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Name = string.sub(stringNum, 1, #stringNum - #tostring(i))..tostring(i)
	
	local label = Instance.new("ImageLabel", button)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Image = hotbarImage
	label.BackgroundTransparency = 1
	label.ImageTransparency = 0.5
	label.ImageColor3 = Color3.fromRGB(31, 31, 31)
	
	local textLabel = Instance.new("TextLabel", label)
	textLabel.AnchorPoint = Vector2.new(1, 0)
	textLabel.Size = UDim2.new(0.35, 0, 0.35, 0)
	textLabel.Position = UDim2.new(1, 0)
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.BackgroundTransparency = 1
	textLabel.TextStrokeTransparency = 1
	textLabel.Text = i
	
	button.MouseButton1Click:Connect(function()
		swapTo(i)
	end)
end

local tweenInfo = TweenInfo.new(
	tweenTime,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out
)

function swapTo(num)
	for i, v in pairs(frame:GetChildren()) do
		local button = v:IsA("ImageButton")
		
		if button and v.ImageLabel.Rotation ~= 0 then
			local tween = tweenService:Create(v.ImageLabel, tweenInfo, {Rotation = 0})
			tween:Play()
		end
	end
	
	if num == currentSelected then
		currentSelected = nil
		return
	end
	
	local stringNum = "000"
	local frame = frame:FindFirstChild(string.sub(stringNum, 1, #stringNum - #tostring(num))..tostring(num))
	if frame then
		local tween = tweenService:Create(frame.ImageLabel, tweenInfo, {Rotation = -12})
		tween:Play()
		
		--[[
		put code here to equip what ever is in the hotbar slot
		--]]
	end
	
	currentSelected = num
end


userInputService.InputBegan:Connect(function(input, gameProccessed)
	if not gameProccessed and (input.KeyCode.Value >= 49 and input.KeyCode.Value <= 57) then
		local num = input.KeyCode.Value - 48
		
		swapTo(num)
	end
end)
