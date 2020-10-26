local module = {
	event_garbage = {}
}

local players = game.Players
local player = players.LocalPlayer

local camera = workspace.CurrentCamera

local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")


local xAngle
local yAngle
local camSensitivity
local cameraOffset
local aimCameraOffset
local targetCameraOffset
local lerpSpeed
local maxRotation
local popDisMultiplier


function module:new()
	local char = player.Character
	local rootPart = char.HumanoidRootPart
	
	local neck = char.Head.Neck
	local neckOrigin = neck.C0
	
	local waist = char.UpperTorso.Waist
	local waistOrigin = waist.C0
	
	xAngle = 0
	yAngle = 0
	camSensitivity = 0.4
	cameraOffset = Vector3.new(2.25, 0, 5)
	aimCameraOffset = Vector3.new(1.25, 0, 2)
	targetCameraOffset = cameraOffset
	lerpSpeed = 0.25
	maxRotation = 0.6
	popDisMultiplier = 1.16
	
	
	local aa
	
	local inputChange = userInputService.InputChanged:Connect(function(input, gameProcessed)
		if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseMovement then
			xAngle = xAngle - input.Delta.x * camSensitivity
			yAngle = math.clamp(yAngle - input.Delta.y * camSensitivity, -80, 80)
		end
	end)
	table.insert(self.event_garbage, inputChange)
	
	local inputBegan = userInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 then
			targetCameraOffset = aimCameraOffset
		end
	end)
	table.insert(self.event_garbage, inputBegan)
	
	local inputEnded = userInputService.inputEnded:Connect(function(input, gameProcessed)
		if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 then
			targetCameraOffset = cameraOffset
		end
	end)
	table.insert(self.event_garbage, inputEnded)
	
	local render = runService.RenderStepped:Connect(function()
		userInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		
		local startCFrame = CFrame.new((rootPart.CFrame.p + Vector3.new(0, 2, 0))) * CFrame.Angles(0, math.rad(xAngle), 0) * CFrame.Angles(math.rad(yAngle), 0, 0)
		local cameraCFrame = startCFrame + startCFrame:vectorToWorldSpace(targetCameraOffset)
		local cameraFocus = startCFrame + startCFrame:vectorToWorldSpace(targetCameraOffset - Vector3.new(0, 0, targetCameraOffset.Z))
		camera.CFrame = CFrame.new(cameraCFrame.p, cameraFocus.p)
		
		--uses :GetLargestCutoffDistance() to check if any parts are inbetwene the player and the camera
		local popDistance = camera:GetLargestCutoffDistance({char}) * popDisMultiplier
		camera.CFrame = camera.CFrame - (popDistance * (camera.CFrame.p - rootPart.CFrame.p).unit)

		--rotates character to look in the direction of the camera on the y-axis
		local charCFrame = char:GetPrimaryPartCFrame()
		char:SetPrimaryPartCFrame(CFrame.new(charCFrame.p, charCFrame.p + Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)))

		--rotates torso and head to look in direction of camera on the x-axis
		local diff = char.Head.CFrame.Y - camera.CFrame.Y
		local dist = (char.Head.CFrame.p - camera.CFrame.p).magnitude
		neck.C0 = neck.C0:lerp(neckOrigin * CFrame.Angles(math.asin(diff / dist) * maxRotation, 0, 0), lerpSpeed)
		waist.C0 = waist.C0:lerp(waistOrigin * CFrame.Angles(math.asin(diff / dist) * maxRotation, 0, 0), lerpSpeed)
	end)
	table.insert(self.event_garbage, render)
end

function module:clean()
	local types = {
		["RBXScriptConnection"] = function(a)
			a:Disconnect()
		end
	}
	
	for _, v in pairs(self.event_garbage) do
		local a = typeof(v)
		
		if types[a] then
			types[a](v)
		end
	end
end


player.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid")
	
	module:new()
end)

player.CharacterRemoving:Connect(function()
	module:clean()
end)



return module
