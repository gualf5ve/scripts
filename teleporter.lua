local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ""
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 40) -- Start minimized
MainFrame.Position = UDim2.new(0.5, -160, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = ""
Title.Size = UDim2.new(0, 200, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.Size = UDim2.new(0, 30, 1, 0)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Text = "_"
MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Parent = TitleBar

-- Search Input
local SearchFrame = Instance.new("Frame")
SearchFrame.Size = UDim2.new(1, -10, 0, 30)
SearchFrame.Position = UDim2.new(0, 5, 0, 35)
SearchFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SearchFrame.Visible = false
SearchFrame.Parent = MainFrame

local SearchBox = Instance.new("TextBox")
SearchBox.PlaceholderText = "Search player..."
SearchBox.Size = UDim2.new(1, 0, 1, 0)
SearchBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = SearchFrame

-- Main Content (hidden when minimized)
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 0, 370)
ContentFrame.Position = UDim2.new(0, 0, 0, 70)
ContentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ContentFrame.Visible = false
ContentFrame.Parent = MainFrame

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, -10, 0, 200)
PlayerList.Position = UDim2.new(0, 5, 0, 0)
PlayerList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerList.Parent = ContentFrame

local TeleportButton = Instance.new("TextButton")
TeleportButton.Text = "Teleport To Player"
TeleportButton.Size = UDim2.new(1, -10, 0, 30)
TeleportButton.Position = UDim2.new(0, 5, 0, 210)
TeleportButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportButton.Parent = ContentFrame

local LoopToggle = Instance.new("TextButton")
LoopToggle.Text = "Enable Loop Teleport"
LoopToggle.Size = UDim2.new(1, -10, 0, 30)
LoopToggle.Position = UDim2.new(0, 5, 0, 250)
LoopToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
LoopToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoopToggle.Parent = ContentFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "Status: Ready"
StatusLabel.Size = UDim2.new(1, -10, 0, 20)
StatusLabel.Position = UDim2.new(0, 5, 0, 290)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = ContentFrame

-- Variables
local SelectedPlayer = nil
local LoopEnabled = false
local LoopConnection = nil
local Minimized = true

-- Functions
local function UpdatePlayerList(searchTerm)
    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local players = Players:GetPlayers()
    table.sort(players, function(a, b) return a.Name:lower() < b.Name:lower() end)
    
    local yOffset = 0
    for _, player in ipairs(players) do
        if player ~= LocalPlayer then
            -- Check if player matches search term (if any)
            if not searchTerm or searchTerm == "" or string.find(player.Name:lower(), searchTerm:lower()) then
                local playerButton = Instance.new("TextButton")
                playerButton.Text = player.Name
                playerButton.Size = UDim2.new(1, -10, 0, 30)
                playerButton.Position = UDim2.new(0, 5, 0, yOffset)
                playerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                playerButton.Parent = PlayerList
                
                playerButton.MouseButton1Click:Connect(function()
                    SelectedPlayer = player
                    StatusLabel.Text = "Status: Selected " .. player.Name
                end)
                
                yOffset = yOffset + 35
            end
        end
    end
    
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

local function TeleportToPlayer(player)
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        StatusLabel.Text = "Status: Error - Player not valid"
        return false
    end
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        StatusLabel.Text = "Status: Error - Your character not valid"
        return false
    end
    
    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
    StatusLabel.Text = "Status: Teleported to " .. player.Name
    return true
end

local function ToggleLoopTeleport()
    LoopEnabled = not LoopEnabled
    
    if LoopEnabled then
        if not SelectedPlayer then
            StatusLabel.Text = "Status: Error - No player selected"
            LoopEnabled = false
            LoopToggle.Text = "Enable Loop Teleport"
            return
        end
        
        LoopToggle.Text = "Disable Loop Teleport"
        LoopToggle.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        StatusLabel.Text = "Status: Loop Teleport enabled for " .. SelectedPlayer.Name
        
        if LoopConnection then
            LoopConnection:Disconnect()
        end
        
        LoopConnection = RunService.Heartbeat:Connect(function()
            if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                TeleportToPlayer(SelectedPlayer)
            else
                StatusLabel.Text = "Status: Error - Player not valid"
                LoopEnabled = false
                LoopToggle.Text = "Enable Loop Teleport"
                LoopToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                if LoopConnection then
                    LoopConnection:Disconnect()
                end
            end
        end)
    else
        LoopToggle.Text = "Enable Loop Teleport"
        LoopToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        StatusLabel.Text = "Status: Loop Teleport disabled"
        
        if LoopConnection then
            LoopConnection:Disconnect()
        end
    end
end

local function ToggleMinimize()
    Minimized = not Minimized
    
    if Minimized then
        MainFrame.Size = UDim2.new(0, 320, 0, 40)
        ContentFrame.Visible = false
        SearchFrame.Visible = false
        MinimizeButton.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 320, 0, 440)
        ContentFrame.Visible = true
        SearchFrame.Visible = true
        MinimizeButton.Text = "_"
    end
end

-- Connect events
TeleportButton.MouseButton1Click:Connect(function()
    if SelectedPlayer then
        TeleportToPlayer(SelectedPlayer)
    else
        StatusLabel.Text = "Status: Error - No player selected"
    end
end)

LoopToggle.MouseButton1Click:Connect(ToggleLoopTeleport)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    if LoopConnection then
        LoopConnection:Disconnect()
    end
end)

MinimizeButton.MouseButton1Click:Connect(ToggleMinimize)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    UpdatePlayerList(SearchBox.Text)
end)

-- Initial setup
UpdatePlayerList()
Players.PlayerAdded:Connect(function()
    UpdatePlayerList(SearchBox.Text)
end)
Players.PlayerRemoving:Connect(function()
    UpdatePlayerList(SearchBox.Text)
end)

-- Close with ESC
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Escape then
        if ScreenGui then
            ScreenGui:Destroy()
            if LoopConnection then
                LoopConnection:Disconnect()
            end
        end
    end
end)

-- Auto-select first player in list when searching
local function autoSelectFirstPlayer()
    local buttons = PlayerList:GetChildren()
    for _, child in ipairs(buttons) do
        if child:IsA("TextButton") then
            SelectedPlayer = Players:FindFirstChild(child.Text)
            StatusLabel.Text = "Status: Selected " .. child.Text
            break
        end
    end
end

SearchBox.FocusLost:Connect(function()
    autoSelectFirstPlayer()
end)
