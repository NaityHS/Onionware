local OnionBotUPD = "https://discord.com/api/webhooks/1489191244469899435/OyR_cpDFsmDqiFWLce7I-Wseg8XjQtLSxbh3Y7y_aMb_DUy1dM6dHYywLvAvO1FlCRSo"
local rs2 = game:GetService("RunService")
local lp = game:GetService("Players").LocalPlayer
local conn
local staminaEnabled = false

local function startStamina()
if conn then return end

conn = rs2.Heartbeat:Connect(function()  
    if not staminaEnabled then return end  
      
    local char = lp.Character  
    if not char then return end  
      
    local max = char:GetAttribute("MaxStamina") or 100  
    local current = char:GetAttribute("Stamina") or max  
      
    if current < max then  
        char:SetAttribute("Stamina", max)  
    end  
end)

end

local function stopStamina()
if conn then
conn:Disconnect()
conn = nil
end
end

lp.CharacterAdded:Connect(function()
task.wait(1)
if staminaEnabled then
startStamina()
end
end)

-- UI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
Title = "Onionware",
Icon = "shrimp",
Author = "woah woah woah",
})

local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local VisualTab = Window:Tab({ Title = "Visual", Icon = "eye" })
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local ServersTab = Window:Tab({ Title = "Servers", Icon = "server" })

-- ================================
-- PLAYER TAB
-- ================================

PlayerTab:Toggle({
Title = "Inf Stamina",
Callback = function(state)
staminaEnabled = state
if state then startStamina() else stopStamina() end
end
})

-- NOCLIP
local noclipConn
PlayerTab:Toggle({
Title = "Noclip",
Callback = function(state)
if state then
noclipConn = rs2.Stepped:Connect(function()
local char = lp.Character
if not char then return end
for _,v in ipairs(char:GetDescendants()) do
if v:IsA("BasePart") then v.CanCollide = false end
end
end)
else
if noclipConn then noclipConn:Disconnect() end
end
end
})
-- Fullbright
local oldLighting = {}
VisualTab:Toggle({
Title = "Fullbright",
Callback = function(state)
local lighting = game:GetService("Lighting")
if state then
oldLighting.Brightness = lighting.Brightness
oldLighting.ClockTime = lighting.ClockTime
oldLighting.FogEnd = lighting.FogEnd
oldLighting.GlobalShadows = lighting.GlobalShadows
oldLighting.Ambient = lighting.Ambient
lighting.Brightness = 5
lighting.ClockTime = 14
lighting.FogEnd = 100000
lighting.GlobalShadows = false
lighting.Ambient = Color3.fromRGB(255,255,255)
else
if next(oldLighting) then
lighting.Brightness = oldLighting.Brightness
lighting.ClockTime = oldLighting.ClockTime
lighting.FogEnd = oldLighting.FogEnd
lighting.GlobalShadows = oldLighting.GlobalShadows
lighting.Ambient = oldLighting.Ambient
end
end
end
})

-- Auto Generator
local AutoGen = false
local genConn

PlayerTab:Toggle({
Title = "Auto Generator",
    Desc = "NOT LEGIT",
Callback = function(v)
AutoGen = v
if AutoGen then
genConn = rs2.RenderStepped:Connect(function()
if lp.PlayerGui:FindFirstChild("Gen") then
lp.PlayerGui.Gen.GeneratorMain.Event:FireServer(true)
end
end)
else
if genConn then genConn:Disconnect() end
end
end
})

-- Auto Escape
local autoEscape = false
local autoEscapeConn

TeleportTab:Toggle({
Title = "Auto Escape",
    Desc = "Tps you to the exit when is 6 AM",
Callback = function(state)
autoEscape = state
if state then
local teleported = false
autoEscapeConn = rs2.RenderStepped:Connect(function()
if teleported or not autoEscape then return end
local char = lp.Character
if not char then return end
if not workspace.GAME.CAN_ESCAPE.Value then return end
local playersFolder = workspace:FindFirstChild("PLAYERS")
if not playersFolder or char.Parent ~= playersFolder:FindFirstChild("ALIVE") then return end
local gameMap = workspace.MAPS:FindFirstChild("GAME MAP")
if not gameMap then return end
local escapes = gameMap:FindFirstChild("Escapes")
if not escapes then return end
for _,part in pairs(escapes:GetChildren()) do
if part:IsA("BasePart") and part:GetAttribute("Enabled") then
local highlight = part:FindFirstChildOfClass("Highlight")
if highlight and highlight.Enabled then
local root = char:FindFirstChild("HumanoidRootPart")
if root then
teleported = true
root.Anchored = true
char.PrimaryPart.CFrame = part.CFrame
task.delay(1.5,function() if root then root.Anchored = false end end)
task.delay(10,function() teleported = false end)
end
end
end
end
end)
else
if autoEscapeConn then autoEscapeConn:Disconnect() end
end
end
})

-- Auto Barricade
local dotEnabled = false
local dotConn

PlayerTab:Toggle({
Title = "Auto Barricade",
Callback = function(state)
dotEnabled = state
local gui = lp:WaitForChild("PlayerGui")
if state then
dotConn = rs2.RenderStepped:Connect(function()
local dot = gui:FindFirstChild("Dot")
if dot and dot:IsA("ScreenGui") then
local container = dot:FindFirstChild("Container")
if container then
local frame = container:FindFirstChild("Frame")
if frame and frame:IsA("GuiObject") then
if not dot.Enabled then
dot:Destroy()
return
end
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.new(0.5,0,0.5,0)
end
end
end
end)
else
if dotConn then dotConn:Disconnect() end
end
end
})

-- ================================
-- ANTI TRAP
-- ================================
local antiTrap = false
local trapConnection = nil
local lastTeleportTime = 0

local function getAllTraps()
    local traps = {}
    local ignore = workspace:FindFirstChild("IGNORE")
    if not ignore then return traps end
    
    -- Pega qualquer coisa com nome "Trap" dentro do IGNORE
    for _, obj in ipairs(ignore:GetDescendants()) do
        if obj.Name == "Trap" and obj:IsA("BasePart") then
            table.insert(traps, obj)
        end
    end
    return traps
end

PlayerTab:Toggle({
Title = "Anti Trap",
Callback = function(v)
antiTrap = v

if antiTrap then  
        lastTeleportTime = 0  
          
        trapConnection = rs2.Heartbeat:Connect(function()  
            local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")  
            if not root then return end  

            local currentTime = tick()  
            if currentTime - lastTeleportTime < 1 then  
                return  
            end  

            -- Pega todas as traps atuais
            local allTraps = getAllTraps()
            
            for _, trap in ipairs(allTraps) do  
                if trap and trap:IsA("BasePart") then  
                    local distance = (trap.Position - root.Position).Magnitude  
                      
                    if distance < 12 then  
                        local lookDir = root.CFrame.LookVector  
                        local teleportOffset = lookDir * 16  
                        local targetPos = root.Position + teleportOffset  

                        local rayParams = RaycastParams.new()  
                        rayParams.FilterDescendantsInstances = {root.Parent}  
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude  

                        local rayResult = workspace:Raycast(root.Position, teleportOffset, rayParams)  

                        if not rayResult or (rayResult.Instance == trap) then  
                            root.CFrame = CFrame.new(targetPos)  
                            lastTeleportTime = currentTime  
                            break  
                        end  
                    end  
                end  
            end  
        end)  
    else  
        if trapConnection then  
            trapConnection:Disconnect()  
            trapConnection = nil  
        end  
    end  
end

})

-- Anti Death
local antiDeath = {
enabled = false,
threshold = 30,
conn = nil,
lastPos = nil,
teleported = false,
debounce = false,
plate = nil
}

local speed = 25

local function getRoot()
local char = lp.Character or lp.CharacterAdded:Wait()
return char:WaitForChild("HumanoidRootPart")
end

local function lerpMove(targetCF)
local root = getRoot()
local startCF = root.CFrame
local dist = (startCF.Position - targetCF.Position).Magnitude
local duration = dist / speed

local t = 0  

while t < duration do  
    t += rs2.Heartbeat:Wait()  
    local alpha = math.clamp(t / duration,0,1)  
    root.CFrame = startCF:Lerp(targetCF,alpha)  
end  

root.CFrame = targetCF

end

local function returnToLastPos()
if antiDeath.plate then
antiDeath.plate:Destroy()
antiDeath.plate = nil
end

if antiDeath.lastPos then  
    task.spawn(function()  
        lerpMove(antiDeath.lastPos)  
    end)  
end  

antiDeath.lastPos = nil  
antiDeath.teleported = false

end

PlayerTab:Toggle({
Title = "Anti Death",
Callback = function(state)
antiDeath.enabled = state

if state then  
        antiDeath.conn = rs2.Heartbeat:Connect(function()  
            local char = lp.Character  
            if not char then return end  

            local hum = char:FindFirstChildOfClass("Humanoid")  
            if not hum then return end  

            local root = char:FindFirstChild("HumanoidRootPart")  
            if not root then return end  

            if hum.Health < antiDeath.threshold and hum.Health > 0 and not antiDeath.teleported and not antiDeath.debounce then  
                antiDeath.debounce = true  
                antiDeath.teleported = true  
                antiDeath.lastPos = root.CFrame  

                local pos = root.Position  

                antiDeath.plate = Instance.new("Part")  
                antiDeath.plate.Size = Vector3.new(50,1,50)  
                antiDeath.plate.Anchored = true  
                antiDeath.plate.Position = pos - Vector3.new(0,100,0)  
                antiDeath.plate.Name = "AntiDeathPlate"  
                antiDeath.plate.Parent = workspace  

                task.spawn(function()  
                    lerpMove(CFrame.new(pos - Vector3.new(0,95,0)))  
                end)  

                task.delay(1,function()  
                    antiDeath.debounce = false  
                end)  

            elseif hum.Health >= antiDeath.threshold and antiDeath.teleported and antiDeath.lastPos and not antiDeath.debounce then  
                antiDeath.debounce = true  
                returnToLastPos()  
                task.delay(1,function()  
                    antiDeath.debounce = false  
                end)  
            end  
        end)  
    else  
        if antiDeath.conn then  
            antiDeath.conn:Disconnect()  
        end  
        if antiDeath.teleported then  
            returnToLastPos()  
        end  
        antiDeath.debounce = false  
    end  
end

})

PlayerTab:Slider({
    Title = "Health Threshold",
    Desc = "basically, if the value is 20, anti death will trigger when u get 20 or less health",
    Value = { Min = 1, Max = 80, Default = 20 },
    Callback = function(value)
        antiDeath.threshold = value
    end
})

-- ================================
-- TELEPORT TAB
-- ================================

local lerping = false
local currentTarget = nil

local function lerpTo(targetCFrame)
    local char, root = lp.Character, nil
    if not char then return end
    root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local targetPos = targetCFrame.Position

    if currentTarget and (currentTarget - targetPos).Magnitude < 0.5 then
        lerping = false
        currentTarget = nil
        return
    end

    currentTarget = targetPos
    lerping = true

    while lerping and root.Parent do
        local currentPos = root.Position
        local direction = (targetPos - currentPos)
        local distance = direction.Magnitude
        
        if distance <= 0.5 then
            break
        end
        
        local step = math.min(speed * rs2.RenderStepped:Wait(), distance)
        root.CFrame = CFrame.new(currentPos + direction.Unit * step, targetPos)
    end

    if lerping and root.Parent then
        root.CFrame = CFrame.new(targetPos)
    end

    lerping = false
    currentTarget = nil
end

-- Safe Place (Safety Area)
local safeTeleport = false
local safePart = nil

local function TeleportTo(model)
    if not model then return end
    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    local frontCFrame = part.CFrame * CFrame.new(0, 0, -5)
    lerpTo(frontCFrame)
end

TeleportTab:Toggle({
Title = "Safe Place",
Callback = function(state)
safeTeleport = state

local char = lp.Character  
    if not char then return end  

    local root = char:FindFirstChild("HumanoidRootPart")  
    if not root then return end  

    if state then  
        local pos = root.Position  

        safePart = Instance.new("Part")  
        safePart.Size = Vector3.new(50,1,50)  
        safePart.Anchored = true  
        safePart.Position = pos - Vector3.new(0,100,0)  
        safePart.Name = "SafetyPlate"  
        safePart.Parent = workspace  

        task.spawn(function()  
            lerpMove(CFrame.new(pos - Vector3.new(0,95,0)))  
        end)  

    else  
        local pos = root.Position  

        if safePart then  
            safePart:Destroy()  
            safePart = nil  
        end  

        task.spawn(function()  
            lerpMove(CFrame.new(pos + Vector3.new(0,100,0)))  
        end)  
    end  
end

})
TeleportTab:Button({
    Title = "Get Back to lobby",
    Desc = "use this only if u are in a black box",
    Callback = function()

        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

        -- Coordenadas fixas
        local targetPosition = Vector3.new(471.6, 57.3, 109.2)

        -- Função de teleport
        local function teleportToPosition()
            humanoidRootPart.CFrame = CFrame.new(targetPosition)
        end

        -- Executa o teleport
        teleportToPosition()

    end
})


-- ================================
-- ESP SYSTEM
-- ================================

local camera = workspace.CurrentCamera

local ESP = {
    Survivors = false,
    Killer = false,
    Fuse = false,
    Generator = false,
    Traps = false,
    Objects = {},
    Connection = nil
}

local function createESP(type)
    local obj = Drawing.new(type)
    obj.Visible = false
    return obj
end

local function clearESP()
    for _,v in pairs(ESP.Objects) do
        for _,o in pairs(v) do
            o:Remove()
        end
    end
    ESP.Objects = {}

    if ESP.Connection then
        ESP.Connection:Disconnect()
        ESP.Connection = nil
    end
end

local function getTargets()
    local targets = {}
    local folders = workspace:FindFirstChild("PLAYERS")

    if folders then
        if ESP.Survivors then
            local alive = folders:FindFirstChild("ALIVE")
            if alive then
                for _,v in ipairs(alive:GetChildren()) do
                    table.insert(targets, {model = v, color = Color3.fromRGB(255,255,255)})
                end
            end
        end

        if ESP.Killer then
            local killer = folders:FindFirstChild("KILLER")
            if killer then
                for _,v in ipairs(killer:GetChildren()) do
                    table.insert(targets, {model = v, color = Color3.fromRGB(255,0,0)})
                end
            end
        end
    end

    if ESP.Generator then
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:lower():find("generator") then
                table.insert(targets, {model = v, color = Color3.fromRGB(0,255,0)})
            end
        end
    end

    if ESP.Fuse then
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:lower():find("fuse") then
                table.insert(targets, {model = v, color = Color3.fromRGB(255,255,0)})
            end
        end
    end

    if ESP.Traps then
        local ignore = workspace:FindFirstChild("IGNORE")
        if ignore then
            for _, obj in ipairs(ignore:GetDescendants()) do
                if obj.Name == "Trap" and (obj:IsA("BasePart") or obj:IsA("Model")) then
                    -- Laranja para as Traps
                    table.insert(targets, {model = obj, color = Color3.fromRGB(255, 150, 0)})
                end
            end
        end
    end

    return targets
end

local function startESP()
    if ESP.Connection then return end

    ESP.Connection = rs2.RenderStepped:Connect(function()
        local targets = getTargets()

        for _,objs in pairs(ESP.Objects) do
            for _,o in pairs(objs) do
                o.Visible = false
            end
        end

        for i,data in ipairs(targets) do
            local model = data.model
            local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")

            if root then
                local pos, vis = camera:WorldToViewportPoint(root.Position)

                if vis then
                    local top = camera:WorldToViewportPoint(root.Position + Vector3.new(0,3,0))
                    local sizeY = math.abs(top.Y - pos.Y) * 2
                    local sizeX = sizeY / 1.5

                    local objs = ESP.Objects[i]
                    if not objs then
                        objs = {
                            box = createESP("Square"),
                            name = createESP("Text"),
                            dist = createESP("Text")
                        }

                        objs.box.Thickness = 2
                        objs.box.Filled = false

                        objs.name.Size = 13
                        objs.name.Center = true
                        objs.name.Outline = true

                        objs.dist.Size = 13
                        objs.dist.Center = true
                        objs.dist.Outline = true

                        ESP.Objects[i] = objs
                    end

                    local char = lp.Character
                    local distance = 0
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        distance = (char.HumanoidRootPart.Position - root.Position).Magnitude
                    end

                    objs.box.Size = Vector2.new(sizeX, sizeY)
                    objs.box.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                    objs.box.Color = data.color
                    objs.box.Visible = true

                    objs.name.Text = model.Name
                    objs.name.Position = Vector2.new(pos.X, pos.Y - sizeY/2 - 14)
                    objs.name.Color = data.color
                    objs.name.Visible = true

                    objs.dist.Text = math.floor(distance).."m"
                    objs.dist.Position = Vector2.new(pos.X, pos.Y + sizeY/2 + 2)
                    objs.dist.Color = data.color
                    objs.dist.Visible = true
                end
            end
        end
    end)
end

-- VISUAL TOGGLES
VisualTab:Toggle({
    Title = "Survivor ESP",
    Callback = function(v)
        ESP.Survivors = v
        clearESP()
        if v or ESP.Killer or ESP.Fuse or ESP.Generator or ESP.Traps then startESP() end
    end
})

VisualTab:Toggle({
    Title = "Killer ESP",
    Callback = function(v)
        ESP.Killer = v
        clearESP()
        if v or ESP.Survivors or ESP.Fuse or ESP.Generator or ESP.Traps then startESP() end
    end
})

VisualTab:Toggle({
    Title = "Generator ESP",
    Callback = function(v)
        ESP.Generator = v
        clearESP()
        if v or ESP.Survivors or ESP.Killer or ESP.Fuse or ESP.Traps then startESP() end
    end
})

VisualTab:Toggle({
    Title = "FuseBox ESP",
    Desc = "idk what this do",
    Callback = function(v)
        ESP.Fuse = v
        clearESP()
        if v or ESP.Survivors or ESP.Killer or ESP.Generator or ESP.Traps then startESP() end
    end
})

VisualTab:Toggle({
    Title = "Trap ESP",
    Callback = function(v)
        ESP.Traps = v
        clearESP()
        if v or ESP.Survivors or ESP.Killer or ESP.Generator or ESP.Fuse then startESP() end
    end
})


local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- discord
local InviteCode = "AuytXr9VFj"

local function GetDiscordInviteData(code)
local url = "https://discord.com/api/v10/invites/" .. code .. "?with_counts=true"

local success, response = pcall(function()  
    return game:HttpGet(url)  
end)  

if not success then  
    return nil, response  
end  

local decoded  
success, decoded = pcall(function()  
    return HttpService:JSONDecode(response)  
end)  

if not success then  
    return nil, decoded  
end  

return decoded

end

-- CORRIGIDO: Criando os elementos da aba Servers corretamente
task.spawn(function()
local Response, Error = GetDiscordInviteData(InviteCode)

if Response and Response.guild then
local DiscordInfo = ServersTab:Paragraph({
Title = Response.guild.name,
Desc = '<font color="#52525b">•</font> Member Count : ' .. tostring(Response.approximate_member_count) ..
'\n <font color="#16a34a">•</font> Online Count : ' .. tostring(Response.approximate_presence_count),
Image = not RunService:IsStudio()
and ("https://cdn.discordapp.com/icons/" ..
Response.guild.id .. "/" .. Response.guild.icon .. ".png?size=1024")
or "rbxassetid://88876696246404",
ImageSize = 42,
Thumbnail = not RunService:IsStudio()
and ("https://cdn.discordapp.com/banners/" ..
Response.guild.id .. "/" .. (Response.guild.banner or "") .. ".png?size=512")
or "rbxassetid://88876696246404",
})

ServersTab:Button({  
    Title = "Update Discord Info",  
    Callback = function()  
        local UpdatedResponse = GetDiscordInviteData(InviteCode)  

        if UpdatedResponse and UpdatedResponse.guild then  
            DiscordInfo:SetDesc(  
                '<font color="#52525b">•</font> Member Count : ' .. tostring(UpdatedResponse.approximate_member_count) ..  
                '\n <font color="#16a34a">•</font> Online Count : ' .. tostring(UpdatedResponse.approximate_presence_count)  
            )  
        end  
    end  
})

else
ServersTab:Paragraph({
Title = "Error when receiving information about the Discord server",
Desc = Error and tostring(Error) or "No data",
Image = "solar:info-circle-bold",
ImageSize = 26,
Color = "Red",
})
end

-- join discord
ServersTab:Button({
Title = "Join Discord server",
Callback = function()
local link = "https://discord.gg/" .. InviteCode

if setclipboard then  
        setclipboard(link)  
    else  
        WindUI:Notify({  
            Title = "Discord Invite Link",  
            Content = link,  
        })  
    end  
end

})
end)