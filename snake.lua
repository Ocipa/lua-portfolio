--K.E. (Ocipa), October 2020


local players = game.Players
local player = players.LocalPlayer

local userInputService = game:GetService("UserInputService")

local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.IgnoreGuiInset = true


local gSize = 35 --size of the grid e.g. 25x25 grid
local start = Vector2.new(math.floor(gSize / 2), math.floor(gSize / 2))
local moveDirection = Vector2.new(0, -1)
local nextMoveDirection

timePerUpdate = 0.1 --the amount fo time per 'frame'

local snake = {}
local grid = {}

local isAlive = true

gridTextureId = false --false or a decal id

--[[ states
0 == blank
1 == snake
2 == food
]]

local colors = {
	[0] = Color3.fromRGB(225, 225, 225),
	[1] = Color3.fromRGB(170, 0, 0),
	[2] = Color3.fromRGB(0, 125, 0)
}

local frame = Instance.new("Frame", screenGui)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.SizeConstraint = Enum.SizeConstraint.RelativeYY
frame.Size = UDim2.new(0.9, 0, 0.9, 0)
frame.Position = UDim2.new(0.5, 0, 0.5, 9)

local resetButton = Instance.new("TextButton", screenGui)
resetButton.AnchorPoint = Vector2.new(0.5, 0.5)
resetButton.Size = UDim2.new(0, 200, 0, 100)
resetButton.Position = UDim2.new(0.5, 0, 0.5, 0)
resetButton.Text = "RESET"
resetButton.Font = Enum.Font.SourceSansBold
resetButton.TextSize = 36
resetButton.BorderSizePixel = 1
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
resetButton.Visible = false

resetButton.MouseButton1Click:Connect(function()
	reset()

	resetButton.Visible = false
end)

function generateGrid()
	for y=1, gSize do
		grid[y] = {}
		for x=1, gSize do
			local label = Instance.new("ImageLabel", frame)
			label.Size = UDim2.new(1 / gSize, 0, 1 / gSize, 0)
			label.Position = UDim2.new(1 / gSize * (x - 1), 0, 1 / gSize * (y - 1), 0)
			label.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
			label.BorderSizePixel = 1
			label.BorderColor3 = Color3.fromRGB(0, 0, 0)
			
			label.Image = gridTextureId or ""
			
			grid[y][x] = {label, 0}
		end
	end
end

function spawnSnake()
	snake = {}
	
	table.insert(snake, 1, start)
	
	grid[start.Y][start.X][2] = 1
end

function killSnake()
	isAlive = false
	
	resetButton.Visible = true
end

function spawnFood()
	local food
	
	repeat
		wait()
		
		local a = Vector2.new(math.random(1, gSize), math.random(1, gSize))
		if grid[a.Y][a.X][2] == 0 then
			food = a
		end
	until food
	
	grid[food.Y][food.X][2] = 2
	grid[food.Y][food.X][1].BackgroundColor3 = colors[2]
end

function reset()
	for y=1, gSize do
		for x=1, gSize do
			grid[y][x][1].BackgroundColor3 = colors[0]
			grid[y][x][2] = 0
		end
	end
	moveDirection = Vector2.new(0, -1)
	nextMoveDirection = nil
	
	snake = {}
	
	spawnFood()
	spawnSnake()
	
	isAlive = true
end

function update()
	if isAlive then
		moveDirection = nextMoveDirection or moveDirection
		nextMoveDirection = nil
		
		for i, v in pairs(snake) do
			grid[v.Y][v.X][1].BackgroundColor3 = colors[0]
		end
		
		local a = snake[1]
		
		local nextHead = snake[1] + moveDirection
		
		if not (grid[nextHead.Y] and grid[nextHead.Y][nextHead.X]) then
			killSnake()
			
			return
		end
		
		for _, v in pairs(snake) do
			if v == nextHead then
				killSnake()

				return
			end
		end
		
		table.insert(snake, 1, nextHead)
		if grid[nextHead.Y][nextHead.X][2] == 2 then
			grid[nextHead.Y][nextHead.X][2] = 0
			spawnFood()
		else
			table.remove(snake, #snake)
		end
		
		for i, v in pairs(snake) do
			grid[v.Y][v.X][1].BackgroundColor3 = colors[1]
		end
	end
end

local keybinds = {
	[Enum.KeyCode.W] = Vector2.new(0, -1),
	[Enum.KeyCode.Up] = Vector2.new(0, -1),
	
	[Enum.KeyCode.S] = Vector2.new(0, 1),
	[Enum.KeyCode.Down] = Vector2.new(0, 1),
	
	[Enum.KeyCode.A] = Vector2.new(-1, 0),
	[Enum.KeyCode.Left] = Vector2.new(-1, 0),
	
	[Enum.KeyCode.D] = Vector2.new(1, 0),
	[Enum.KeyCode.Right] = Vector2.new(1, 0),
}

userInputService.InputBegan:Connect(function(input)
	local bound = keybinds[input.KeyCode]
	if bound and ((#snake > 1 and bound + moveDirection ~= Vector2.new(0, 0)) or #snake == 1) then
		nextMoveDirection = bound
	end
end)



generateGrid()
spawnSnake()
spawnFood()


local lastUpdate = 0
while true do
	wait()
	if lastUpdate + timePerUpdate < tick() then
		lastUpdate = tick()
		
		update()
	end
end
