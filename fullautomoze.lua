local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local RemoteEvent = ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Packet"):WaitForChild("RemoteEvent")
local LocalPlayer = Players.LocalPlayer
local Networking = require(ReplicatedStorage.SharedModules.Networking)
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

local antiAfkEnabled = true

-- MENGAMBIL KONFIGURASI DARI LUAR (GETGENV)
local Config = getgenv().MuzeAutoBuyConfig or {
    BuySeeds = false,
    BuyGears = false,
    AutoSell = true, -- Fitur Baru
    Delay = 10,
    Seeds = {},
    Gears = {}
}

-- 1. BYPASS TUTORIAL
local function completeTutorialInstantly()
    print("[1/6] Bypass tutorial...")
    pcall(function()
        RemoteEvent:FireServer(buffer.fromstring("C\x01"))
    end)
end

-- 2. TELEPORT KE STEVEN
local function teleportToSteven()
    print("[2/6] Teleport ke Steven (5x percobaan tiap 5 detik)...")
    local steven = Workspace:FindFirstChild("Steven", true)
    
    if not steven then
        repeat
            task.wait(1)
            steven = Workspace:FindFirstChild("Steven", true)
        until steven
    end

    local target = (steven:IsA("Model") and (steven.PrimaryPart or steven:FindFirstChild("HumanoidRootPart"))) or (steven:IsA("BasePart") and steven)
    
    if target then
        for i = 1, 5 do
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                print(" -> Teleport " .. i .. "/5")
                root.CFrame = target.CFrame + Vector3.new(0, 3, 3)
                root.Anchored = true 
                
                -- FITUR ANTI VOID
                local platName = "AntiVoidPlatform_Steven"
                if not Workspace:FindFirstChild(platName) then
                    local plat = Instance.new("Part")
                    plat.Name = platName
                    plat.Size = Vector3.new(50, 2, 50)
                    plat.Position = root.Position - Vector3.new(0, 4, 0)
                    plat.Anchored = true
                    plat.Transparency = 1 
                    plat.Parent = Workspace
                end
            end
            task.wait(5)
        end
    end
end

-- 3. AUTO CLAIM MAIL
local function startAutoClaimMail()
    print("[3/6] Mengaktifkan Auto Claim Mail (tiap 30s)...")
    task.spawn(function()
        while true do
            local ok, inbox = pcall(function() return Networking.Mailbox.OpenInbox:Fire() end)
            if ok and typeof(inbox) == "table" then
                for id in pairs(inbox) do
                    pcall(function() Networking.Mailbox.Claim:Fire(id) end)
                    task.wait(0.3)
                end
            end
            task.wait(30)
        end
    end)
end

-- ==========================
-- FPS BOOST HELPERS
-- ==========================
local function getParentType(desc)
    local current = desc
    local isFruit = false
    local isPlant = false
    
    while current and current ~= Workspace do
        if current.Name == "Fruits" then isFruit = true end
        if current.Name == "Plants" then isPlant = true end
        current = current.Parent
    end
    
    return isFruit, isPlant
end

local function superBrutalize(desc)
    if desc:IsA("ParticleEmitter") or desc:IsA("Beam") or desc:IsA("Trail") or desc:IsA("Fire") or desc:IsA("Smoke") or desc:IsA("Sparkles") or desc:IsA("Light") or desc:IsA("PostEffect") or desc:IsA("Texture") or desc:IsA("Decal") or desc:IsA("SurfaceAppearance") then
        pcall(function() desc:Destroy() end)
        return
    end
    
    if desc:IsA("Motor6D") or desc:IsA("Animator") or desc:IsA("AnimationController") then
        pcall(function() desc:Destroy() end)
        return
    end

    if desc:IsA("BasePart") then
        desc.CastShadow = false
        
        local isFruit, isPlant = getParentType(desc)
        
        if desc.Name == "HarvestPart" then
            desc.Transparency = 0.5
            desc.Color = Color3.fromRGB(0, 255, 0) 
            desc.Material = Enum.Material.Neon
            
        elseif isFruit then
            desc.Material = Enum.Material.SmoothPlastic
            desc.Reflectance = 0
            
        elseif isPlant then
            if desc.Name ~= "Base" then
                desc.Transparency = 1
                desc.CanCollide = false 
            end
            desc.Anchored = true
            
        else
            desc.Material = Enum.Material.SmoothPlastic
            desc.Reflectance = 0
            if desc.Parent and not desc.Parent:FindFirstChild("Humanoid") then
                desc.Anchored = true
            end
        end
    end
end

local function nukeEnvironment()
    local annoyingStuff = {"BirdVisuals", "Birds", "BlizzardBeams", "Weather", "Clouds", "Rain"}
    for _, name in ipairs(annoyingStuff) do
        local obj = Workspace:FindFirstChild(name)
        if obj then pcall(function() obj:Destroy() end) end
    end
    
    if Terrain then
        pcall(function()
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
            Terrain.Decoration = false
        end)
    end
end

-- 4. FPS BOOST
local function applyFpsBoost()
    print("[4/6] Mengaktifkan Brutal FPS Boost & Custom Black Screen...")
    
    local objectsToDestroy = {"MidLayer", "Baseplate", "Middle", "Grass", "Gardens", "SpawnPoint"}
    for _, name in pairs(objectsToDestroy) do 
        if Workspace:FindFirstChild(name) then Workspace[name]:Destroy() end 
    end
    
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 0 
        for _, child in pairs(Lighting:GetChildren()) do
            if child:IsA("BloomEffect") or child:IsA("BlurEffect") or child:IsA("ColorCorrectionEffect") or child:IsA("SunRaysEffect") or child:IsA("DepthOfFieldEffect") or child:IsA("Atmosphere") or child:IsA("Sky") or child:IsA("PostEffect") then 
                child:Destroy() 
            end
        end
    end)
    
    nukeEnvironment()
    
    local char = LocalPlayer.Character
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if char and desc:IsDescendantOf(char) then continue end
        superBrutalize(desc)
    end
    
    Workspace.CurrentCamera.FieldOfView = 30

    pcall(function()
        local bgGui = Instance.new("ScreenGui")
        bgGui.Name = "AFK_BlackScreen"
        bgGui.IgnoreGuiInset = true
        bgGui.ResetOnSpawn = false
        
        local bgFrame = Instance.new("Frame")
        bgFrame.Size = UDim2.new(1, 0, 1, 0)
        bgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bgFrame.BorderSizePixel = 0
        bgFrame.Parent = bgGui

        local leftImage = Instance.new("ImageLabel")
        leftImage.Size = UDim2.new(0.3, 0, 0.6, 0) 
        leftImage.Position = UDim2.new(0.05, 0, 0.5, 0)
        leftImage.AnchorPoint = Vector2.new(0, 0.5)
        leftImage.BackgroundTransparency = 1
        leftImage.ScaleType = Enum.ScaleType.Fit
        leftImage.Image = "rbxassetid://79880397850563"
        leftImage.Parent = bgFrame

        local rightImage = Instance.new("ImageLabel")
        rightImage.Size = UDim2.new(0.3, 0, 0.6, 0)
        rightImage.Position = UDim2.new(0.95, 0, 0.5, 0)
        rightImage.AnchorPoint = Vector2.new(1, 0.5)
        rightImage.BackgroundTransparency = 1
        rightImage.ScaleType = Enum.ScaleType.Fit
        rightImage.Image = "rbxassetid://104624206636533"
        rightImage.Parent = bgFrame
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(0.9, 0, 0.25, 0)
        textLabel.Position = UDim2.new(0.5, 0, 0.95, 0)
        textLabel.AnchorPoint = Vector2.new(0.5, 1)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "AFK MODE ACTIVE\nFENG JIU MY BINI JIR"
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextScaled = true
        textLabel.TextWrapped = true
        textLabel.Font = Enum.Font.Code
        textLabel.ZIndex = 10
        textLabel.Parent = bgFrame
        
        local centerLabel = Instance.new("TextLabel")
        centerLabel.Size = UDim2.new(0.3, 0, 0.4, 0)
        centerLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
        centerLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        centerLabel.BackgroundTransparency = 1
        centerLabel.Text = "Loading..."
        centerLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        centerLabel.TextScaled = true
        centerLabel.TextWrapped = false
        centerLabel.Font = Enum.Font.GothamBold
        centerLabel.ZIndex = 10
        centerLabel.Parent = bgFrame
        
        local textConstraint = Instance.new("UITextSizeConstraint")
        textConstraint.MaxTextSize = 35
        textConstraint.Parent = centerLabel
        
        local centerStroke = Instance.new("UIStroke")
        centerStroke.Thickness = 1.5
        centerStroke.Color = Color3.fromRGB(0, 0, 0)
        centerStroke.Parent = centerLabel
        
        task.spawn(function()
            while true do
                local sheckles = "0"
                pcall(function()
                    sheckles = tostring(LocalPlayer.leaderstats.Sheckles.Value)
                end)
                local function formatNumber(n)
                    n = tonumber(n) or 0
                    if n >= 1e12 then
                        return string.format("%.2fT", n / 1e12)
                    elseif n >= 1e9 then
                        return string.format("%.2fB", n / 1e9)
                    elseif n >= 1e6 then
                        return string.format("%.2fM", n / 1e6)
                    elseif n >= 1e3 then
                        return string.format("%.1fK", n / 1e3)
                    else
                        return tostring(n)
                    end
                end
                centerLabel.Text = "👤 " .. LocalPlayer.Name .. "\n💰 " .. formatNumber(sheckles)
                task.wait(1)
            end
        end)

        local success = pcall(function() bgGui.Parent = CoreGui end)
        if not success then
            bgGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end

        RunService:Set3dRenderingEnabled(false)
        if setfpscap then setfpscap(15) end
    end)
end

-- 5. AUTO BUY (MENGGUNAKAN GETGENV CONFIG)
local function startAutoBuy()
    print("[5/6] Mengaktifkan Auto Buy (Dari Config Luar)...")
    
    task.spawn(function()
        while true do
            -- Loop Seed
            if Config.BuySeeds and Config.Seeds then
                for itemName, isEnabled in pairs(Config.Seeds) do 
                    if isEnabled == true then
                        local payloadString = "{\000" .. string.char(#itemName) .. itemName
                        local args = { buffer.fromstring(payloadString) }
                        for i = 1, 3 do 
                            pcall(function() RemoteEvent:FireServer(unpack(args)) end)
                            task.wait(0.3) 
                        end
                    end
                end
            end
            
            -- Loop Gear
            if Config.BuyGears and Config.Gears then
                for itemName, isEnabled in pairs(Config.Gears) do 
                    if isEnabled == true then
                        local payloadString = "\127\000" .. string.char(#itemName) .. itemName
                        local args = { buffer.fromstring(payloadString) }
                        for i = 1, 3 do 
                            pcall(function() RemoteEvent:FireServer(unpack(args)) end)
                            task.wait(0.3)
                        end
                    end
                end
            end
            
            -- Jeda dari config, default 10 detik
            task.wait(Config.Delay or 10)
        end
    end)
end

-- ==========================
-- AUTO SELL HELPERS (DARI SCRIPT.TXT)
-- ==========================
local utilityTools = {
    ["Basic Pot"] = true, ["Watering Can"] = true, ["Trowel"] = true,
    ["Super Trowel"] = true, ["Golden Trowel"] = true,
    ["Infinite Watering Can"] = true, ["Seed Bag"] = true,
}

local function isSellableFruit(item)
    if not item:IsA("Tool") then return false end
    if utilityTools[item.Name] then return false end
    
    -- Filter item-item penting agar tidak terjual
    local patterns = {"Pot", "Can", "Trowel", "Bag", "Fertilizer", "Axe", "Pickaxe", "Shovel", "Sprinkler", "Seed"}
    for _, p in ipairs(patterns) do
        if item.Name:find(p) then return false end
    end
    
    return true
end

local function PerformSell()
    local fruits = {}
    
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if isSellableFruit(item) then table.insert(fruits, item) end
    end
    if LocalPlayer.Character then
        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
            if isSellableFruit(item) then table.insert(fruits, item) end
        end
    end

    if #fruits > 0 then
        pcall(function() Networking.NPCS.SellAll:Fire() end)
        task.wait()

        local stillHasFruits = false
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if isSellableFruit(item) then
                stillHasFruits = true
                break
            end
        end

        if stillHasFruits then
            for _, tool in ipairs(fruits) do
                local id = tool:GetAttribute("Id")
                if id and tool.Parent then
                    pcall(function() Networking.NPCS.SellFruit:Fire(id) end)
                    task.wait()
                end
            end
        end
    end
end

-- 6. AUTO DAILY DEAL & AUTO SELL
local function startAutoDailyDealAndSell()
    print("[6/6] Mengaktifkan Auto Daily Deal (10 Detik) & Auto Sell (3 Menit)...")
    
    -- Loop 1: Auto Daily Deal (Tiap 10 detik)
    task.spawn(function()
        while true do
            if Config.AutoSell then
                print("[Auto Daily Deal] Mengeksekusi Daily Deal...")
                pcall(function()
                    RemoteEvent:FireServer(unpack({buffer.fromstring("\xB4\000\x13")}))
                    task.wait(0.5)
                    RemoteEvent:FireServer(unpack({buffer.fromstring("\xB7\000\x14")}))
                    task.wait(0.5)
                    RemoteEvent:FireServer(unpack({buffer.fromstring("\xB8\000")}))
                end)
                print("[!] Daily Deal dieksekusi.")
            end
            task.wait(10) -- Jeda 10 detik
        end
    end)
    
    -- Loop 2: Auto Sell All (Tiap 3 menit)
    task.spawn(function()
        while true do
            if Config.AutoSell then
                pcall(function()
                    PerformSell()
                end)
            end
            task.wait(180) -- Jeda 3 menit
        end
    end)
end


-- ANTI AFK
local function setupAntiAFK()
    print("[+] Anti-AFK diaktifkan.")
    
    LocalPlayer.Idled:Connect(function()
        if antiAfkEnabled then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)

    task.spawn(function()
        while true do
            task.wait(math.random(150, 240)) 
            
            if antiAfkEnabled then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
                
                pcall(function()
                    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.Jump = true
                    end
                end)
            end
        end
    end)
end

-- AUTO ADD & ACCEPT FRIEND
local function startAutoFriend()
    print("[+] Mengaktifkan Auto Add & Accept Friend...")
    task.spawn(function()
        while true do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    pcall(function()
                        LocalPlayer:RequestFriendship(player)
                    end)
                end
            end
            task.wait(10)
        end
    end)
end

-- ==========================
-- --- EKSEKUSI URUTAN ---
-- ==========================
setupAntiAFK()
startAutoFriend()

task.spawn(function()
    -- 1. BYPASS TUTORIAL
    local function isInTutorial()
        local char = LocalPlayer.Character
        return Workspace:GetAttribute("InTutorial") or (char and char:GetAttribute("InTutorial"))
    end

    if isInTutorial() then
        completeTutorialInstantly()
        local waitTime = 0
        while isInTutorial() do
            task.wait(0.5)
            waitTime = waitTime + 0.5
            if waitTime >= 30 then
                print("[!] Tutorial stuck selama 30 detik! Memaksa rejoin...")
                local ts = game:GetService("TeleportService")
                pcall(function() ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
                task.wait(3)
                pcall(function() ts:Teleport(game.PlaceId, LocalPlayer) end)
                break
            end
        end
        task.wait(1)
    end
    
    -- 2. TELEPORT KE STEVEN
    teleportToSteven()
    task.wait(1)
    
    -- 3. AUTO CLAIM MAIL
    startAutoClaimMail()
    task.wait(0.5)
    
    -- 4. FPS BOOST
    applyFpsBoost()
    task.wait(0.5)
    
    -- 5. AUTO BUY
    startAutoBuy()
    task.wait(0.5)
    
    -- 6. AUTO DAILY DEAL & SELL
    startAutoDailyDealAndSell()
    
    print("[+] Selesai! Semua fitur telah dijalankan dan sedang bekerja di latar belakang.")
end)
