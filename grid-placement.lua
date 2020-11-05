--K.E. (Ocipa), Novemeber 2020

--[[
put in a local script
--]]

local collectionService = game:GetService("CollectionService")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local players = game.Players
local player = players.LocalPlayer

local camera = workspace.CurrentCamera

local gSize = 4 --the size of the snapping grid and parts
local cursorOffset = Vector2.new(0, -35) --the default cursor is not centered, set this to nil or Vector2.new() if you don't want a offset

local part = Instance.new("Part")
part.Size = Vector3.new(gSize, gSize, gSize)
part.Anchored = true
part.CanCollide = false
part.Transparency = 0.2
part.TopSurface = Enum.SurfaceType.Smooth
part.BottomSurface = Enum.SurfaceType.Smooth

local cursor = Instance.new("Part")
cursor.Size = Vector3.new(0.25, 0.25, 0.25)
cursor.Anchored = true
cursor.CanCollide = false
cursor.Material = Enum.Material.Neon
cursor.Color = Color3.fromRGB(200, 25, 25)
cursor.TopSurface = Enum.SurfaceType.Smooth
cursor.BottomSurface = Enum.SurfaceType.Smooth


runService.RenderStepped:Connect(function()
	local mouse = userInputService:GetMouseLocation() + (cursorOffset or Vector2.new())

	local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {
		part,
		cursor
	}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.IgnoreWater = true

	local rayResults = workspace:Raycast(ray.Origin, ray.Direction * 250, rayParams)
	
	if rayResults then
		local normalPos = rayResults.Position + rayResults.Normal * (gSize / 2)
		
		local xPos = math.floor(normalPos.X / gSize) * gSize + gSize / 2
		local yPos = math.floor(normalPos.Y / gSize) * gSize + gSize / 2
		local zPos = math.floor(normalPos.Z / gSize) * gSize + gSize / 2
		
		part.CFrame = CFrame.new(Vector3.new(xPos, yPos, zPos))
		part.Parent = workspace
		
		cursor.CFrame = CFrame.new(rayResults.Position)
		cursor.Parent = workspace
	else
		part.Parent = nil
		
		cursor.Parent = nil
	end
end)

userInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
		if part.Parent == workspace then
			local clone = part:Clone()
			clone.CanCollide = true
			clone.Transparency = 0
			clone.Parent = workspace
		end
	end
end)

