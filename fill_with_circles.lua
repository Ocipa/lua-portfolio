--K.E. (Ocipa), October 2020

--[[
put in a local script
--]]

local attempts = 2000

local players = game.Players
local player = players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui", playerGui)

local circleId = "rbxassetid://279918838"


local frame = Instance.new("Frame", screenGui)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.SizeConstraint = Enum.SizeConstraint.RelativeYY
frame.Size = UDim2.new(0.9, 0, 0.9, 0)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)


local circles = {}
--circles = {{position, radius}} --position==Vector2, radius==number

function isOccupied(pos2)
	local occupied = false
	
	for _, v in pairs(circles) do
		local pos1 = v[1]
		local radius = v[2]
		
		local distance = math.sqrt(math.pow(pos2.X - pos1.X, 2) + math.pow(pos2.Y - pos1.Y, 2))
		if distance < radius then
			occupied = true
			break
		end
	end
	
	return occupied
end

function distnaceToNeighbor(pos2)
	local dis = math.min(pos2.X, frame.AbsoluteSize.X - pos2.X, pos2.Y, frame.AbsoluteSize.Y - pos2.Y)
	
	for _, v in pairs(circles) do
		local pos1 = v[1]
		local radius = v[2]

		local distance = math.sqrt(math.pow(pos2.X - pos1.X, 2) + math.pow(pos2.Y - pos1.Y, 2)) - radius
		if distance < dis then
			dis = distance
		end
	end

	return dis
end

local count = 0
while count < attempts do
	local pos = Vector2.new(math.random(0, frame.AbsoluteSize.X), math.random(0, frame.AbsoluteSize.Y))
	
	local occupied = isOccupied(pos)
	if not occupied then
		table.insert(circles, {pos, distnaceToNeighbor(pos)})
	else
		count += 1
	end
end

function drawCircles()
	for _, v in pairs(circles) do
		local label = Instance.new("ImageLabel")
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.SizeConstraint = Enum.SizeConstraint.RelativeXX
		label.Size = UDim2.fromOffset(v[2] * 2, v[2] * 2)
		label.Position = UDim2.fromOffset(v[1].X, v[1].Y)
		label.BackgroundTransparency = 1
		label.ImageColor3 = Color3.new(0.921569, 0.352941, 0.0901961)
		label.Image = circleId
		label.Parent = frame
	end
end
drawCircles()
