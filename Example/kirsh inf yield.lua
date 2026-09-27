local kirshlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/KirshWasHere/roblox-ui-lib/refs/heads/main/kirshlib.lua"))()

local window = kirshlib:window({
    Title = "Kirsh Inf Yield",
    Size = UDim2.new(0, 420, 0, 270)
})

local players = game:GetService("Players")
local run = game:GetService("RunService")
local input = game:GetService("UserInputService")
local lighting = game:GetService("Lighting")
local teleport = game:GetService("TeleportService")
local chat = game:GetService("TextChatService")
local storage = game:GetService("ReplicatedStorage")
local pathfinding = game:GetService("PathfindingService")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local state = {
    walkspeed = 16,
    jumppower = 50,
    hipheight = 2,
    gravity = workspace.Gravity,
    flyspeed = 2,
    freecamspeed = 1,
    hitboxsize = 2,
    reachsize = 2,
    orbitangle = 0,
    customspeed = false,
    customjump = false,
    customhip = false,
    noclip = false,
    flying = false,
    spin = false,
    god = false,
    unseen = false,
    esp = false,
    chams = false,
    spam = false,
    infinitejump = false,
    antivoid = false,
    antifling = false,
    sitwalk = false,
    floating = false,
    freecam = false,
    flinging = false,
    clicktp = false,
    loopfling = nil,
    customsound = nil,
    autoreconnect = false,
    antikick = false,
    antiteleport = false,
    chatlog = false,
    trackplayers = false,
    boomboxes = false,
    saved = nil,
    refreshcframe = nil,
    deathcframe = nil,
    bodyvel = nil,
    bodygyro = nil,
    following = nil,
    orbiting = nil,
    watching = nil,
    sittinghead = nil,
    floatpart = nil,
    currenttrack = nil,
    webhookurl = "",
    spamtext = "Kirsh Inf Yield",
    waypoints = {},
    ambient = lighting.Ambient,
    brightness = lighting.Brightness,
    fog = lighting.FogEnd
}

local shared = {}

local char = player.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if hum then
    state.walkspeed = hum.WalkSpeed
    state.jumppower = hum.JumpPower
    state.hipheight = hum.HipHeight
end

do
    local first = window:tab("LocalPlayer")

    local function speed(val)
        state.customspeed = true
        state.walkspeed = val
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.WalkSpeed ~= val then
                player.Character.Humanoid.WalkSpeed = val
            end
        end
    end
    first:slider("WalkSpeed", 16, 500, math.floor(state.walkspeed), speed)

    local function jump(val)
        state.customjump = true
        state.jumppower = val
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.JumpPower ~= val then
                player.Character.Humanoid.UseJumpPower = true
                player.Character.Humanoid.JumpPower = val
            end
        end
    end
    first:slider("JumpPower", 50, 500, math.floor(state.jumppower), jump)

    local function pull(val)
        state.gravity = val
        if workspace.Gravity ~= val then
            workspace.Gravity = val
        end
    end
    first:slider("Gravity", 0, 196, math.floor(state.gravity), pull)

    local function elevate(val)
        state.customhip = true
        state.hipheight = val
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.HipHeight ~= val then
                player.Character.Humanoid.HipHeight = val
            end
        end
    end
    first:slider("HipHeight", 0, 50, math.floor(state.hipheight), elevate)

    local function pace(val)
        state.flyspeed = val
    end
    first:slider("Fly Speed", 1, 10, 2, pace)

    local function hover()
        if state.flying and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local move = Vector3.zero
            if input:IsKeyDown(Enum.KeyCode.W) then
                move = move + camera.CFrame.LookVector
            end
            if input:IsKeyDown(Enum.KeyCode.S) then
                move = move - camera.CFrame.LookVector
            end
            if input:IsKeyDown(Enum.KeyCode.A) then
                move = move - camera.CFrame.RightVector
            end
            if input:IsKeyDown(Enum.KeyCode.D) then
                move = move + camera.CFrame.RightVector
            end
            if input:IsKeyDown(Enum.KeyCode.Space) then
                move = move + Vector3.new(0, 1, 0)
            end
            if input:IsKeyDown(Enum.KeyCode.LeftShift) then
                move = move - Vector3.new(0, 1, 0)
            end
            if state.bodyvel then
                state.bodyvel.Velocity = move * (state.flyspeed * 25)
            end
            if state.bodygyro then
                state.bodygyro.CFrame = camera.CFrame
            end
        end
    end
    run.RenderStepped:Connect(hover)

    local function glide(st)
        state.flying = st
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            if st then
                if not state.bodyvel then
                    state.bodyvel = Instance.new("BodyVelocity")
                    state.bodyvel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    state.bodyvel.Velocity = Vector3.zero
                    state.bodyvel.Parent = root
                end
                if not state.bodygyro then
                    state.bodygyro = Instance.new("BodyGyro")
                    state.bodygyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    state.bodygyro.P = 9e4
                    state.bodygyro.CFrame = camera.CFrame
                    state.bodygyro.Parent = root
                end
                if player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.PlatformStand = true
                end
            else
                if state.bodyvel then
                    state.bodyvel:Destroy()
                    state.bodyvel = nil
                end
                if state.bodygyro then
                    state.bodygyro:Destroy()
                    state.bodygyro = nil
                end
                if player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.PlatformStand = false
                end
            end
        end
    end
    shared.glide = glide
    first:toggle("Fly", false, glide)

    local function pass()
        if state.noclip and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
    run.Stepped:Connect(pass)

    local function ghost(st)
        state.noclip = st
    end
    first:toggle("Noclip", false, ghost)

    local function spring()
        if state.infinitejump and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    input.JumpRequest:Connect(spring)

    local function leap(st)
        state.infinitejump = st
    end
    first:toggle("Infinite Jump", false, leap)

    local function support()
        if state.floating and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not state.floatpart or not state.floatpart.Parent then
                state.floatpart = Instance.new("Part")
                state.floatpart.Size = Vector3.new(6, 1, 6)
                state.floatpart.Anchored = true
                state.floatpart.Transparency = 0.5
                state.floatpart.Parent = workspace
            end
            state.floatpart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, -3.5, 0)
        else
            if state.floatpart then
                state.floatpart:Destroy()
                state.floatpart = nil
            end
        end
    end
    run.RenderStepped:Connect(support)

    local function float(st)
        state.floating = st
        if not st and state.floatpart then
            state.floatpart:Destroy()
            state.floatpart = nil
        end
    end
    first:toggle("Float Platform", false, float)

    local function stroll()
        if state.sitwalk and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Sit = true
        end
    end
    run.RenderStepped:Connect(stroll)

    local function crawl(st)
        state.sitwalk = st
    end
    first:toggle("Sit Walk", false, crawl)

    local function pivot(st)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.AutoRotate = st
        end
    end
    first:toggle("Auto Rotate", true, pivot)

    local function heal(st)
        state.god = st
        while state.god do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                if player.Character.Humanoid.Health < player.Character.Humanoid.MaxHealth then
                    player.Character.Humanoid.Health = player.Character.Humanoid.MaxHealth
                end
            end
            task.wait(0.2)
        end
    end
    first:toggle("God", false, heal)

    local function rescue(st)
        state.antivoid = st
        while state.antivoid do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                if root.Position.Y < workspace.FallenPartsDestroyHeight + 50 then
                    root.Velocity = Vector3.zero
                    root.CFrame = CFrame.new(root.Position.X, 50, root.Position.Z)
                end
            end
            task.wait(0.5)
        end
    end
    first:toggle("Anti Void", false, rescue)

    local function guard()
        if state.antifling then
            for _, p in pairs(players:GetPlayers()) do
                if p ~= player and p.Character then
                    for _, part in pairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end
    run.Stepped:Connect(guard)

    local function shield(st)
        state.antifling = st
    end
    first:toggle("Anti Fling", false, shield)

    local function vanish(st)
        state.unseen = st
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = st and 1 or 0
                    if part:IsA("Decal") then
                        part.Transparency = st and 1 or 0
                    end
                end
            end
        end
    end
    first:toggle("Invisible", false, vanish)

    local function twirl(st)
        state.spin = st
        if st then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rot = Instance.new("BodyAngularVelocity")
                rot.Name = "Spin"
                rot.Parent = player.Character.HumanoidRootPart
                rot.MaxTorque = Vector3.new(0, math.huge, 0)
                rot.AngularVelocity = Vector3.new(0, 20, 0)
            end
        else
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rot = player.Character.HumanoidRootPart:FindFirstChild("Spin")
                if rot then rot:Destroy() end
            end
        end
    end
    first:toggle("Spin", false, twirl)

    local function stand(st)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = st
        end
    end
    first:toggle("Platform", false, stand)

    local function freeze()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = true
        end
    end
    first:button("Freeze", freeze)

    local function thaw()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = false
        end
    end
    first:button("Thaw", thaw)

    local function rest()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Sit = true
        end
    end
    first:button("Sit", rest)

    local function tumble()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
        end
    end
    first:button("Trip", tumble)

    local function die()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 0
        end
    end
    first:button("Reset", die)

    local function refresh()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            state.refreshcframe = player.Character.HumanoidRootPart.CFrame
            player.Character.Humanoid.Health = 0
        end
    end
    first:button("Refresh", refresh)

    local function cube()
        if player.Character and player.Character:FindFirstChild("Head") then
            local mesh = player.Character.Head:FindFirstChildOfClass("SpecialMesh")
            if mesh then mesh:Destroy() end
        end
    end
    first:button("Block Head", cube)

    local function box()
        if player.Character then
            for _, acc in pairs(player.Character:GetChildren()) do
                if acc:IsA("Accessory") and acc:FindFirstChild("Handle") then
                    local mesh = acc.Handle:FindFirstChildOfClass("SpecialMesh")
                    if mesh then mesh:Destroy() end
                end
            end
        end
    end
    first:button("Block Hats", box)

    local function trim()
        if player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part.Name == "Right Arm" or part.Name == "Left Arm" or part.Name == "RightUpperArm" or part.Name == "LeftUpperArm" then
                    part:Destroy()
                end
            end
        end
    end
    first:button("Creeper Body", trim)

    local function drop()
        if player.Character then
            for _, acc in pairs(player.Character:GetChildren()) do
                if acc:IsA("Accessory") and acc:FindFirstChild("Handle") then
                    acc.Parent = workspace
                end
            end
        end
    end
    first:button("Drop Hats", drop)

    local function strip()
        if player.Character then
            for _, item in pairs(player.Character:GetChildren()) do
                if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                    item:Destroy()
                end
            end
        end
    end
    first:button("Strip Clothes", strip)

    local function blank()
        if player.Character and player.Character:FindFirstChild("Head") then
            local decal = player.Character.Head:FindFirstChildOfClass("Decal")
            if decal then decal:Destroy() end
        end
    end
    first:button("Remove Face", blank)

    local function shed()
        if player.Character then
            for _, item in pairs(player.Character:GetChildren()) do
                if item:IsA("Accessory") then
                    item:Destroy()
                end
            end
        end
    end
    first:button("Drop Accessories", shed)

    local function sever()
        if player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "Head" and part.Name ~= "Torso" and part.Name ~= "UpperTorso" and part.Name ~= "LowerTorso" then
                    part:Destroy()
                end
            end
        end
    end
    first:button("Remove Limbs", sever)
end

do
    local second = window:tab("Combat")

    local function resolve(txt)
        local list = {}
        local term = string.lower(txt)
        if term == "all" then
            for _, p in pairs(players:GetPlayers()) do
                table.insert(list, p)
            end
        elseif term == "others" then
            for _, p in pairs(players:GetPlayers()) do
                if p ~= player then
                    table.insert(list, p)
                end
            end
        elseif term == "me" then
            table.insert(list, player)
        elseif term == "random" then
            local all = players:GetPlayers()
            if #all > 0 then
                table.insert(list, all[math.random(1, #all)])
            end
        else
            for _, p in pairs(players:GetPlayers()) do
                if string.lower(string.sub(p.Name, 1, string.len(term))) == term then
                    table.insert(list, p)
                    break
                end
            end
        end
        return list
    end

    local function arm()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            for _, item in pairs(player.Backpack:GetChildren()) do
                if item:IsA("Tool") then
                    player.Character.Humanoid:EquipTool(item)
                end
            end
        end
    end
    second:button("Equip All", arm)

    local function disarm()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:UnequipTools()
        end
    end
    second:button("Unequip All", disarm)

    local function gather()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
                    obj.Handle.CFrame = root.CFrame
                end
            end
        end
    end
    second:button("Grab Dropped Tools", gather)

    local function propel()
        if state.flinging and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local current = root.Velocity
            root.Velocity = current * 10000 + Vector3.new(0, 10000, 0)
            run.RenderStepped:Wait()
            root.Velocity = current
        end
    end
    run.Heartbeat:Connect(propel)

    local function fling(st)
        state.flinging = st
    end
    second:toggle("Fling", false, fling)

    local function blast()
        if state.loopfling and state.loopfling.Character and state.loopfling.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetpart = state.loopfling.Character.HumanoidRootPart
            local root = player.Character.HumanoidRootPart
            root.CFrame = targetpart.CFrame
            root.Velocity = Vector3.new(9e5, 9e5, 9e5)
        end
    end
    run.Heartbeat:Connect(blast)

    local function hurl(txt)
        if txt == "" then
            state.loopfling = nil
        else
            local targets = resolve(txt)
            state.loopfling = targets[1]
        end
    end
    second:input("Loop Fling", "Username", hurl)

    local function trap(txt)
        local targets = resolve(txt)
        for _, target in pairs(targets) do
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local center = target.Character.HumanoidRootPart.Position
                local positions = {
                    center + Vector3.new(0, -3.5, 0),
                    center + Vector3.new(0, 3.5, 0),
                    center + Vector3.new(3.5, 0, 0),
                    center + Vector3.new(-3.5, 0, 0),
                    center + Vector3.new(0, 0, 3.5),
                    center + Vector3.new(0, 0, -3.5)
                }
                local sizes = {
                    Vector3.new(8, 1, 8),
                    Vector3.new(8, 1, 8),
                    Vector3.new(1, 8, 8),
                    Vector3.new(1, 8, 8),
                    Vector3.new(8, 8, 1),
                    Vector3.new(8, 8, 1)
                }
                for i = 1, 6 do
                    local wall = Instance.new("Part")
                    wall.Size = sizes[i]
                    wall.CFrame = CFrame.new(positions[i])
                    wall.Anchored = true
                    wall.Transparency = 0.5
                    wall.Parent = workspace
                end
            end
        end
    end
    second:input("Trap Player", "Username", trap)

    local function expand(charobj)
        if state.hitboxsize > 2 and charobj and charobj ~= player.Character then
            local root = charobj:FindFirstChild("HumanoidRootPart")
            if root then
                root.Size = Vector3.new(state.hitboxsize, state.hitboxsize, state.hitboxsize)
                root.Transparency = 0.7
                root.CanCollide = false
            end
        end
    end
    shared.expand = expand

    local function inflate(val)
        state.hitboxsize = val
        for _, p in pairs(players:GetPlayers()) do
            if p ~= player and p.Character then
                expand(p.Character)
            end
        end
    end
    second:slider("Hitbox Size", 2, 50, 2, inflate)

    local function extend(val)
        state.reachsize = val
        if player.Character then
            for _, item in pairs(player.Character:GetChildren()) do
                if item:IsA("Tool") and item:FindFirstChild("Handle") then
                    item.Handle.Size = Vector3.new(val, val, val)
                    item.Handle.Massless = true
                    item.Handle.CanCollide = false
                end
            end
        end
    end
    second:slider("Tool Reach", 2, 50, 2, extend)
end

do
    local third = window:tab("Visuals")

    local function view()
        for _, p in pairs(players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("HumanoidRootPart") then
                local tag = p.Character.Head:FindFirstChild("ESP")
                if state.esp then
                    if not tag then
                        tag = Instance.new("BillboardGui")
                        tag.Name = "ESP"
                        tag.Size = UDim2.new(0, 100, 0, 40)
                        tag.StudsOffset = Vector3.new(0, 2, 0)
                        tag.AlwaysOnTop = true
                        tag.Parent = p.Character.Head
                        
                        local text = Instance.new("TextLabel")
                        text.Size = UDim2.new(1, 0, 1, 0)
                        text.BackgroundTransparency = 1
                        text.TextColor3 = Color3.new(1, 0, 0)
                        text.TextStrokeTransparency = 0
                        text.Text = p.Name
                        text.Parent = tag
                    end
                else
                    if tag then tag:Destroy() end
                end

                local glow = p.Character:FindFirstChild("CHAMS")
                if state.chams then
                    if not glow then
                        glow = Instance.new("Highlight")
                        glow.Name = "CHAMS"
                        glow.FillColor = Color3.new(1, 0, 0)
                        glow.OutlineColor = Color3.new(1, 1, 1)
                        glow.FillTransparency = 0.5
                        glow.Parent = p.Character
                    end
                else
                    if glow then glow:Destroy() end
                end
            end
        end
    end

    local function render()
        if state.esp or state.chams then view() end
    end
    run.RenderStepped:Connect(render)

    local function names(st)
        state.esp = st
        if not st then view() end
    end
    third:toggle("ESP", false, names)

    local function highlight(st)
        state.chams = st
        if not st then view() end
    end
    third:toggle("Chams", false, highlight)

    local function bright(st)
        if st then
            lighting.Ambient = Color3.new(1, 1, 1)
            lighting.Brightness = 2
        else
            lighting.Ambient = state.ambient
            lighting.Brightness = state.brightness
        end
    end
    third:toggle("Fullbright", false, bright)

    local function clear(st)
        if st then
            lighting.FogEnd = 100000
        else
            lighting.FogEnd = state.fog
        end
    end
    third:toggle("Clear Fog", false, clear)

    local function shadow(st)
        lighting.GlobalShadows = st
    end
    third:toggle("Shadows", true, shadow)

    local function peer(st)
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") then
                if st then
                    if not obj:GetAttribute("Original") then
                        obj:SetAttribute("Original", obj.Transparency)
                    end
                    obj.Transparency = 0.5
                else
                    if obj:GetAttribute("Original") then
                        obj.Transparency = obj:GetAttribute("Original")
                    end
                end
            end
        end
    end
    third:toggle("Xray", false, peer)

    local function shine(val)
        lighting.Brightness = val
    end
    third:slider("Brightness", 1, 10, math.floor(lighting.Brightness), shine)
end

do
    local fourth = window:tab("Camera")

    local function resolve(txt)
        local list = {}
        local term = string.lower(txt)
        if term == "all" then
            for _, p in pairs(players:GetPlayers()) do
                table.insert(list, p)
            end
        elseif term == "others" then
            for _, p in pairs(players:GetPlayers()) do
                if p ~= player then
                    table.insert(list, p)
                end
            end
        elseif term == "me" then
            table.insert(list, player)
        elseif term == "random" then
            local all = players:GetPlayers()
            if #all > 0 then
                table.insert(list, all[math.random(1, #all)])
            end
        else
            for _, p in pairs(players:GetPlayers()) do
                if string.lower(string.sub(p.Name, 1, string.len(term))) == term then
                    table.insert(list, p)
                    break
                end
            end
        end
        return list
    end

    local function drift()
        if state.freecam then
            camera.CameraType = Enum.CameraType.Scriptable
            local move = Vector3.zero
            if input:IsKeyDown(Enum.KeyCode.W) then
                move = move + camera.CFrame.LookVector
            end
            if input:IsKeyDown(Enum.KeyCode.S) then
                move = move - camera.CFrame.LookVector
            end
            if input:IsKeyDown(Enum.KeyCode.A) then
                move = move - camera.CFrame.RightVector
            end
            if input:IsKeyDown(Enum.KeyCode.D) then
                move = move + camera.CFrame.RightVector
            end
            if input:IsKeyDown(Enum.KeyCode.E) then
                move = move + Vector3.new(0, 1, 0)
            end
            if input:IsKeyDown(Enum.KeyCode.Q) then
                move = move - Vector3.new(0, 1, 0)
            end
            camera.CFrame = camera.CFrame + move * state.freecamspeed
        end
    end
    run.RenderStepped:Connect(drift)

    local function roam(st)
        state.freecam = st
        if not st then
            camera.CameraType = Enum.CameraType.Custom
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = player.Character.Humanoid
            end
        end
    end
    fourth:toggle("Freecam", false, roam)

    local function shift(val)
        state.freecamspeed = val
    end
    fourth:slider("Freecam Speed", 1, 10, 1, shift)

    local function focus()
        player.CameraMode = Enum.CameraMode.LockFirstPerson
    end
    fourth:button("First Person", focus)

    local function detach()
        player.CameraMode = Enum.CameraMode.Classic
    end
    fourth:button("Third Person", detach)

    local function repair()
        camera.CameraType = Enum.CameraType.Custom
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = player.Character.Humanoid
        end
    end
    fourth:button("Fix Camera", repair)

    local function spectate(txt)
        local targets = resolve(txt)
        if #targets > 0 and targets[1].Character and targets[1].Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = targets[1].Character.Humanoid
        end
    end
    fourth:input("View Player", "Username", spectate)

    local function revert()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = player.Character.Humanoid
        end
    end
    fourth:button("Revert View", revert)

    local function align(st)
        player.DevEnableMouseLock = st
    end
    fourth:toggle("Shift Lock", true, align)

    local function zoom(val)
        camera.FieldOfView = val
    end
    fourth:slider("FOV", 70, 120, math.floor(camera.FieldOfView), zoom)

    local function narrow(val)
        player.CameraMinZoomDistance = val
    end
    fourth:slider("Min Zoom", 0, 50, 0, narrow)

    local function widen(val)
        player.CameraMaxZoomDistance = val
    end
    fourth:slider("Max Zoom", 50, 1000, 400, widen)
end

do
    local fifth = window:tab("Teleports")

    local function resolve(txt)
        local list = {}
        local term = string.lower(txt)
        if term == "all" then
            for _, p in pairs(players:GetPlayers()) do
                table.insert(list, p)
            end
        elseif term == "others" then
            for _, p in pairs(players:GetPlayers()) do
                if p ~= player then
                    table.insert(list, p)
                end
            end
        elseif term == "me" then
            table.insert(list, player)
        elseif term == "random" then
            local all = players:GetPlayers()
            if #all > 0 then
                table.insert(list, all[math.random(1, #all)])
            end
        else
            for _, p in pairs(players:GetPlayers()) do
                if string.lower(string.sub(p.Name, 1, string.len(term))) == term then
                    table.insert(list, p)
                    break
                end
            end
        end
        return list
    end

    local function search(txt)
        local targets = resolve(txt)
        if #targets > 0 and targets[1].Character and targets[1].Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = targets[1].Character.HumanoidRootPart.CFrame
        end
    end
    fifth:input("Teleport Player", "Username", search)

    local function drag(txt)
        local targets = resolve(txt)
        for _, p in pairs(targets) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, -3)
            end
        end
    end
    fifth:input("Bring Player", "Username", drag)

    local function follow(txt)
        if txt == "" then
            state.following = nil
        else
            local targets = resolve(txt)
            state.following = targets[1]
        end
    end
    fifth:input("Follow Player", "Username", follow)

    local function circle(txt)
        if txt == "" then
            state.orbiting = nil
        else
            local targets = resolve(txt)
            state.orbiting = targets[1]
        end
    end
    fifth:input("Orbit Player", "Username", circle)

    local function gaze(txt)
        if txt == "" then
            state.watching = nil
        else
            local targets = resolve(txt)
            state.watching = targets[1]
        end
    end
    fifth:input("Watch Player", "Username", gaze)

    local function perch(txt)
        if txt == "" then
            state.sittinghead = nil
        else
            local targets = resolve(txt)
            state.sittinghead = targets[1]
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Sit = true
            end
        end
    end
    fifth:input("Head Sit", "Username", perch)

    local function pursue()
        if state.following and state.following.Character and state.following.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:MoveTo(state.following.Character.HumanoidRootPart.Position)
        end
        if state.orbiting and state.orbiting.Character and state.orbiting.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            state.orbitangle = state.orbitangle + 0.05
            local targetpos = state.orbiting.Character.HumanoidRootPart.Position
            local offset = Vector3.new(math.cos(state.orbitangle) * 10, 2, math.sin(state.orbitangle) * 10)
            player.Character.HumanoidRootPart.CFrame = CFrame.new(targetpos + offset, targetpos)
        end
        if state.watching and state.watching.Character and state.watching.Character:FindFirstChild("HumanoidRootPart") then
            camera.CFrame = CFrame.new(camera.CFrame.Position, state.watching.Character.HumanoidRootPart.Position)
        end
        if state.sittinghead and state.sittinghead.Character and state.sittinghead.Character:FindFirstChild("Head") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = state.sittinghead.Character.Head.CFrame + Vector3.new(0, 1.8, 0)
        end
    end
    run.RenderStepped:Connect(pursue)

    local function route(txt)
        local function navigate()
            local targets = resolve(txt)
            local p = targets[1]
            if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("Humanoid") then
                local start = player.Character.HumanoidRootPart.Position
                local finish = p.Character.HumanoidRootPart.Position
                local path = pathfinding:CreatePath()
                path:ComputeAsync(start, finish)
                local points = path:GetWaypoints()
                for _, pt in pairs(points) do
                    if not player.Character or not player.Character:FindFirstChild("Humanoid") then break end
                    player.Character.Humanoid:MoveTo(pt.Position)
                    player.Character.Humanoid.MoveToFinished:Wait()
                end
            end
        end
        task.spawn(navigate)
    end
    fifth:input("Pathfind Player", "Username", route)

    local function guide(txt)
        local function lead()
            local cf = state.waypoints[string.lower(txt)]
            if cf and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                local start = player.Character.HumanoidRootPart.Position
                local finish = cf.Position
                local path = pathfinding:CreatePath()
                path:ComputeAsync(start, finish)
                local points = path:GetWaypoints()
                for _, pt in pairs(points) do
                    if not player.Character or not player.Character:FindFirstChild("Humanoid") then break end
                    player.Character.Humanoid:MoveTo(pt.Position)
                    player.Character.Humanoid.MoveToFinished:Wait()
                end
            end
        end
        task.spawn(lead)
    end
    fifth:input("Pathfind Waypoint", "Name", guide)

    local function port()
        if mouse.Hit and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end

    local function warp()
        if state.clicktp and mouse.Hit and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
    mouse.Button1Down:Connect(warp)

    local function tap(st)
        state.clicktp = st
    end
    fifth:toggle("Click Teleport", false, tap)

    local function tool()
        local item = Instance.new("Tool")
        item.Name = "Teleport"
        item.RequiresHandle = false
        item.Parent = player.Backpack
        item.Activated:Connect(port)
    end
    fifth:button("Teleport Tool", tool)

    local function record()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            state.saved = player.Character.HumanoidRootPart.CFrame
        end
    end
    fifth:button("Record Waypoint", record)

    local function fetch()
        if state.saved and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = state.saved
        end
    end
    fifth:button("Fetch Waypoint", fetch)

    local function recall()
        if state.deathcframe and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = state.deathcframe
        end
    end
    fifth:button("Recall Death", recall)

    local function safe()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local part = Instance.new("Part")
            part.Size = Vector3.new(50, 1, 50)
            part.Position = Vector3.new(math.random(-10000, 10000), 10000, math.random(-10000, 10000))
            part.Anchored = true
            part.Parent = workspace
            player.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 5, 0)
        end
    end
    fifth:button("Safe Platform", safe)
end

do
    local sixth = window:tab("Waypoints")

    local function mark(txt)
        if txt ~= "" and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            state.waypoints[string.lower(txt)] = player.Character.HumanoidRootPart.CFrame
        end
    end
    sixth:input("Save Waypoint", "Name", mark)

    local function warp(txt)
        local cf = state.waypoints[string.lower(txt)]
        if cf and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = cf
        end
    end
    sixth:input("Teleport Waypoint", "Name", warp)

    local function purge(txt)
        state.waypoints[string.lower(txt)] = nil
    end
    sixth:input("Delete Waypoint", "Name", purge)

    local function wipe()
        state.waypoints = {}
    end
    sixth:button("Clear Waypoints", wipe)
end

do
    local seventh = window:tab("World")

    local function build()
        for _, bin in pairs({Enum.BinType.Clone, Enum.BinType.Hammer, Enum.BinType.Grab}) do
            local item = Instance.new("HopperBin")
            item.BinType = bin
            item.Parent = player.Backpack
        end
    end
    seventh:button("Build Tools", build)

    local function destroy()
        if mouse.Target then
            mouse.Target:Destroy()
        end
    end

    local function eraser()
        local item = Instance.new("Tool")
        item.Name = "Delete"
        item.RequiresHandle = false
        item.Parent = player.Backpack
        item.Activated:Connect(destroy)
    end
    seventh:button("Eraser Tool", eraser)

    local function obtain()
        local btool = game:GetObjects("rbxassetid://142785488")[1]
        if btool then
            btool.Parent = player.Backpack
        end
    end

    local function craft()
        pcall(obtain)
    end
    seventh:button("Building Tools F3X", craft)

    local function unlock()
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Locked = false
            end
        end
    end
    seventh:button("Unlock Workspace", unlock)

    local function unanchor()
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end
    end
    seventh:button("Unanchor Workspace", unanchor)

    local function activate()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ClickDetector") then
                fireclickdetector(obj)
            end
        end
    end
    seventh:button("Fire Click Detectors", activate)

    local function interact()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                fireproximityprompt(obj)
            end
        end
    end
    seventh:button("Fire Proximity Prompts", interact)

    local function hasten()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                obj.HoldDuration = 0
            end
        end
    end
    seventh:button("Instant Proximity Prompts", hasten)

    local function flatten()
        workspace.Terrain:Clear()
    end
    seventh:button("Clear Terrain", flatten)

    local function smooth()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 1
            end
        end
    end
    seventh:button("Remove Textures", smooth)

    local function boost()
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        for _, item in pairs(game:GetDescendants()) do
            if item:IsA("BasePart") then
                item.Material = Enum.Material.SmoothPlastic
            elseif item:IsA("Decal") or item:IsA("Texture") then
                item:Destroy()
            elseif item:IsA("ParticleEmitter") or item:IsA("Trail") then
                item.Enabled = false
            elseif item:IsA("Explosion") then
                item.Visible = false
            end
        end
    end
    seventh:button("FPS Booster", boost)

    local function noon()
        lighting.TimeOfDay = "12:00:00"
    end
    seventh:button("Set Day", noon)

    local function dark()
        lighting.TimeOfDay = "00:00:00"
    end
    seventh:button("Set Night", dark)

    local function hour(val)
        lighting.TimeOfDay = tostring(val) .. ":00:00"
    end
    seventh:slider("Hour", 0, 24, math.floor(lighting.ClockTime), hour)
end

do
    local eighth = window:tab("Animations")

    local function groove()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humobj = player.Character.Humanoid
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://507771019"
            if humobj.RigType == Enum.HumanoidRigType.R6 then
                anim.AnimationId = "rbxassetid://182435998"
            end
            if state.currenttrack then
                state.currenttrack:Stop()
            end
            state.currenttrack = humobj:LoadAnimation(anim)
            state.currenttrack:Play()
        end
    end
    eighth:button("Dance", groove)

    local function pause()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humobj = player.Character.Humanoid
            local animator = humobj:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(0)
                end
            end
        end
    end
    eighth:button("Freeze Animations", pause)

    local function play()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humobj = player.Character.Humanoid
            local animator = humobj:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(1)
                end
            end
        end
    end
    eighth:button("Resume Animations", play)

    local function cease()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humobj = player.Character.Humanoid
            local animator = humobj:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
            end
        end
        if state.currenttrack then
            state.currenttrack:Stop()
            state.currenttrack = nil
        end
    end
    eighth:button("Stop Animations", cease)

    local function tempo(val)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humobj = player.Character.Humanoid
            local animator = humobj:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(val)
                end
            end
        end
    end
    eighth:slider("Animation Speed", 0, 10, 1, tempo)
end

do
    local ninth = window:tab("Network")

    local function suppress()
        while state.antikick do
            local gui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
            if gui then
                local overlay = gui:FindFirstChild("promptOverlay")
                if overlay then
                    local prompt = overlay:FindFirstChild("ErrorPrompt")
                    if prompt then
                        prompt.Visible = false
                    end
                end
            end
            task.wait(0.5)
        end
    end

    local function resist(st)
        state.antikick = st
        if st then
            task.spawn(suppress)
        end
    end
    ninth:toggle("Anti Kick", false, resist)

    local function stall(st)
        state.antiteleport = st
    end
    ninth:toggle("Anti Teleport", false, stall)

    local function intercept()
        if hookmetamethod then
            local old
            local function hook(self, ...)
                local method = getnamecallmethod()
                if state.antikick and (method == "Kick" or method == "kick") and self == player then
                    return nil
                end
                if state.antiteleport and (method == "Teleport" or method == "TeleportToPlaceInstance") and self == teleport then
                    return nil
                end
                return old(self, ...)
            end
            old = hookmetamethod(game, "__namecall", hook)
        end
    end
    intercept()

    local function gauge()
        local stats = game:GetService("Stats")
        local item = stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
        if item and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local tag = player.Character.HumanoidRootPart:FindFirstChild("PingTag")
            if not tag then
                tag = Instance.new("BillboardGui")
                tag.Name = "PingTag"
                tag.Size = UDim2.new(0, 100, 0, 30)
                tag.AlwaysOnTop = true
                tag.Parent = player.Character.HumanoidRootPart
                local text = Instance.new("TextLabel")
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.TextColor3 = Color3.new(0, 1, 0)
                text.Text = tostring(math.floor(item:GetValue()))
                text.Parent = tag
            else
                local text = tag:FindFirstChildOfClass("TextLabel")
                if text then
                    text.Text = tostring(math.floor(item:GetValue()))
                end
            end
        end
    end
    ninth:button("Check Ping", gauge)
end

do
    local tenth = window:tab("Logs")

    local function forward(txt)
        state.webhookurl = txt
    end
    tenth:input("Webhook URL", "URL", forward)

    local function dispatch(txt)
        if state.webhookurl ~= "" then
            local http = game:GetService("HttpService")
            local req = http_request or request or syn and syn.request
            if req then
                local payload = http:JSONEncode({content = txt})
                req({
                    Url = state.webhookurl,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = payload
                })
            end
        end
    end

    local function transcribe(msg)
        if state.chatlog then
            local content = msg.Text or msg.Message or ""
            local sender = msg.TextSource and msg.TextSource.Name or msg.FromSpeaker or "Player"
            dispatch(sender .. " " .. content)
        end
    end

    if chat.ChatVersion == Enum.ChatVersion.TextChatService then
        chat.MessageReceived:Connect(transcribe)
    else
        local chatevent = storage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatevent and chatevent:FindFirstChild("OnMessageDoneFiltering") then
            chatevent.OnMessageDoneFiltering.OnClientEvent:Connect(transcribe)
        end
    end

    local function listen(st)
        state.chatlog = st
    end
    tenth:toggle("Chat Logs", false, listen)

    local function enter(p)
        if state.trackplayers then
            dispatch(p.Name .. " joined")
        end
        if shared.expand then
            p.CharacterAdded:Connect(shared.expand)
        end
    end
    players.PlayerAdded:Connect(enter)

    local function leave(p)
        if state.trackplayers then
            dispatch(p.Name .. " left")
        end
    end
    players.PlayerRemoving:Connect(leave)

    local function monitor(st)
        state.trackplayers = st
    end
    tenth:toggle("Player Tracker", false, monitor)
end

do
    local eleventh = window:tab("Server")

    local function place()
        if setclipboard then
            setclipboard(tostring(game.PlaceId))
        end
    end
    eleventh:button("Copy Place ID", place)

    local function job()
        if setclipboard then
            setclipboard(tostring(game.JobId))
        end
    end
    eleventh:button("Copy Job ID", job)

    local function count()
        local amount = #players:GetPlayers()
    end
    eleventh:button("Player Count", count)

    local function mute(descendant)
        if state.boomboxes and descendant:IsA("Sound") and descendant.Parent and descendant.Parent:IsA("BasePart") then
            local owner = descendant.Parent.Parent
            if owner and owner:FindFirstChild("Humanoid") and owner ~= player.Character then
                descendant.Volume = 0
            end
        end
    end
    workspace.DescendantAdded:Connect(mute)

    local function silence(st)
        state.boomboxes = st
        for _, p in pairs(players:GetPlayers()) do
            if p ~= player and p.Character then
                for _, s in pairs(p.Character:GetDescendants()) do
                    if s:IsA("Sound") then
                        s.Volume = st and 0 or 1
                    end
                end
            end
        end
    end
    eleventh:toggle("Mute Boomboxes", false, silence)

    local function quiet(st)
        for _, s in pairs(workspace:GetDescendants()) do
            if s:IsA("Sound") then
                if st then
                    if not s:GetAttribute("Volume") then
                        s:SetAttribute("Volume", s.Volume)
                    end
                    s.Volume = 0
                else
                    if s:GetAttribute("Volume") then
                        s.Volume = s:GetAttribute("Volume")
                    end
                end
            end
        end
    end
    eleventh:toggle("Mute Sounds", false, quiet)

    local function rejoin()
        teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end
    eleventh:button("Rejoin", rejoin)

    local function reconnect()
        teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end

    local function detect()
        while state.autoreconnect do
            local gui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
            if gui then
                local prompt = gui:FindFirstChild("promptOverlay")
                if prompt and prompt:FindFirstChild("ErrorPrompt") then
                    reconnect()
                    break
                end
            end
            task.wait(2)
        end
    end

    local function retry(st)
        state.autoreconnect = st
        if st then
            task.spawn(detect)
        end
    end
    eleventh:toggle("Auto Reconnect", false, retry)

    local function hop()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local function query()
            local http = game:GetService("HttpService")
            return http:JSONDecode(game:HttpGet(url))
        end
        local success, result = pcall(query)
        if success and result and result.data then
            for _, srv in pairs(result.data) do
                if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                    teleport:TeleportToPlaceInstance(game.PlaceId, srv.id, player)
                    break
                end
            end
        end
    end
    eleventh:button("Hop", hop)

    local function plus()
        loadstring(game:HttpGet("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"))()
    end
    local function inspect()
        pcall(plus)
    end
    eleventh:button("Dex Plus Plus", inspect)

    local function moon()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end
    local function examine()
        pcall(moon)
    end
    eleventh:button("Moon Dex", examine)

    local function cobalt()
        loadstring(game:HttpGet("https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau"))()
    end
    local function intercept()
        pcall(cobalt)
    end
    eleventh:button("Cobalt Spy", intercept)

    local function simple()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
    end
    local function sniff()
        pcall(simple)
    end
    eleventh:button("Simple Spy", sniff)

    local function log()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua", true))()
    end
    local function capture()
        pcall(log)
    end
    eleventh:button("Audio Logger", capture)

    local function tune(txt)
        local id = string.gsub(txt, "%D", "")
        if id ~= "" then
            if state.customsound then
                state.customsound:Stop()
                state.customsound:Destroy()
                state.customsound = nil
            end
            local audio = Instance.new("Sound")
            audio.SoundId = "rbxassetid://" .. id
            audio.Volume = 1
            audio.Parent = workspace
            audio:Play()
            state.customsound = audio
        end
    end
    eleventh:input("Play Audio", "Asset ID", tune)

    local function halt()
        if state.customsound then
            state.customsound:Stop()
            state.customsound:Destroy()
            state.customsound = nil
        end
    end
    eleventh:button("Stop Audio", halt)

    local function say(txt)
        state.spamtext = txt
    end
    eleventh:input("Say Message", "Message", say)

    local function spammer(st)
        state.spam = st
        local function broadcast()
            while state.spam do
                if chat.ChatVersion == Enum.ChatVersion.TextChatService then
                    chat.TextChannels.RBXGeneral:SendAsync(state.spamtext)
                else
                    storage:FindFirstChild("DefaultChatSystemChatEvents").SayMessageRequest:FireServer(state.spamtext, "All")
                end
                task.wait(1)
            end
        end
        if st then
            task.spawn(broadcast)
        end
    end
    eleventh:toggle("Spammer", false, spammer)
end

do
    local twelfth = window:tab("Credits")
    twelfth:label("Infinite Yield")
    twelfth:label("Original Script by EdgeIY and contributors")
    twelfth:label("Website https://infyiff.github.io/")

    local function copy()
        if setclipboard then
            setclipboard("https://infyiff.github.io/")
        end
    end
    twelfth:button("Copy Website", copy)
end

do
    local function track()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            state.deathcframe = player.Character.HumanoidRootPart.CFrame
        end
    end

    local function bind(charobj)
        local humanoid = charobj:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.Died:Connect(track)
        end
    end
    player.CharacterAdded:Connect(bind)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.Died:Connect(track)
    end

    local function restore(character)
        task.wait(0.2)
        local humanoid = character:WaitForChild("Humanoid", 5)
        local root = character:WaitForChild("HumanoidRootPart", 5)
        if humanoid then
            if state.customspeed and humanoid.WalkSpeed ~= state.walkspeed then
                humanoid.WalkSpeed = state.walkspeed
            end
            if state.customjump and humanoid.JumpPower ~= state.jumppower then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = state.jumppower
            end
            if state.customhip and humanoid.HipHeight ~= state.hipheight then
                humanoid.HipHeight = state.hipheight
            end
        end
        if state.flying and root and shared.glide then
            shared.glide(true)
        end
        if state.refreshcframe and root then
            root.CFrame = state.refreshcframe
            state.refreshcframe = nil
        end
    end
    player.CharacterAdded:Connect(restore)
end
