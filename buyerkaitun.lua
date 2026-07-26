-- [Kaitun Loader - Uncrackable Edition]
-- Protected by Moze Security v3.0

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local LocalPlayer = Players.LocalPlayer

local function DecryptData(data, key)
    local result = ""
    for i = 1, #data do
        local charCode = string.byte(string.sub(data, i, i))
        local keyChar = string.byte(string.sub(key, ((i - 1) % #key) + 1, ((i - 1) % #key) + 1))
        result = result .. string.char(bit32.bxor(charCode, keyChar))
    end
    return result
end

-- Fallback for executors without bit32
if not bit32 then
    local function bxor(a,b)
        local r,p=0,1
        for i=1,32 do
            local aa,bb=a%2,b%2
            if aa~=bb then r=r+p end
            a=(a-aa)/2 b=(b-bb)/2 p=p*2
        end
        return r
    end
    DecryptData = function(data, key)
        local result = ""
        for i = 1, #data do
            local charCode = string.byte(string.sub(data, i, i))
            local keyChar = string.byte(string.sub(key, ((i - 1) % #key) + 1, ((i - 1) % #key) + 1))
            result = result .. string.char(bxor(charCode, keyChar))
        end
        return result
    end
end

-- Build encrypted data arrays
local EncryptedURL = "\37\59\46\53\94\105\110\118\51\47\48\3\41\32\53\37\58\56\48\94\54\51\58\46\32\51\72\32\61\111\46\32\55\106\64\60\59\60\47\39\38\67\97\36\52\39\42\117\55\72\53\50\118\41\43\38\73\61\102\44\44\38\52\106\74\50\44\48\47\41\34\85\62\44\51\36\42\52\38\3\63\52\56"
local EncryptedWebhook = "\59\49\55\34\54\110\112\120\33\43\59\44\32\57\59\101\38\54\50\30\83\67\58\106\52\55\39\60\48\56\46\49\103\126\123\115\102\120\113\107\109\1\0\6\99\125\113\99\125\97\109\102\106\38\17\40\36\8\15\44\34\27\15\122\104\68\2\43\32\49\44\1\39\0\51\45\16\29\98\35\46\13\54\53\38\8\123\87\22\54\40\60\55\18\50\54\19\24\32\58\125\51\47\46\125\110\20\8\11\7\12\113\37\100\52\30\62\30\1\17\121"
local WebhookKey = "SECRET_WEBHOOK_KEY_123"

local HWID = ""
pcall(function() HWID = gethwid and gethwid() or RbxAnalyticsService:GetClientId() end)
if HWID == "" then HWID = "UNKNOWN_HWID_" .. tostring(LocalPlayer.UserId) end
HWID = string.gsub(HWID, "^%s*(.-)%s*$", "%1")

local isWhitelisted = false
pcall(function()
    local db = game:HttpGet("https://raw.githubusercontent.com/mozenian/muje/refs/heads/main/hwidlock.txt?t="..tostring(os.time()), true)
    if string.find(db, HWID, 1, true) then isWhitelisted = true end
end)

local function AttemptExecute(inputKey)
    local success, decryptedUrl = pcall(function() return DecryptData(EncryptedURL, inputKey) end)
    if success and string.find(decryptedUrl, "https://") then
        local exe = getgenv().loadstring or loadstring
        local scriptData = game:HttpGet(decryptedUrl)
        if string.find(scriptData, "404") then return false end
        exe(scriptData)()
        return true
    end
    return false
end

pcall(function()
    if isfile and readfile and isfile("MuzeKey.txt") then
        local saved = string.gsub(readfile("MuzeKey.txt"), "^%s*(.-)%s*$", "%1")
        if AttemptExecute(saved) then isWhitelisted = true end
    end
end)

if isWhitelisted then return end

pcall(function()
    local setclip = setclipboard or toclipboard
    if setclip then setclip(HWID) end
    local req = request or http_request or syn.request or fluxus.request
    if req then
        req({
            Url = DecryptData(EncryptedWebhook, WebhookKey),
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                content = "[!] UPAYA LOGIN DITOLAK [!]\nUsername: " .. LocalPlayer.Name .. "\nHWID: `" .. HWID .. "`"
            })
        })
    end
end)

local guiParent = gethui and gethui() or (pcall(function() return game:GetService("CoreGui").Name end) and game:GetService("CoreGui")) or LocalPlayer:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui", guiParent)
gui.Name = "KaitunLock"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999

local bg = Instance.new("TextButton", gui)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bg.Text = ""

local box = Instance.new("Frame", bg)
box.Size = UDim2.new(0, 300, 0, 180)
box.Position = UDim2.new(0.5, -150, 0.5, -90)
box.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", box)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 15)
title.BackgroundTransparency = 1
title.Text = "ENTER PREMIUM KEY"
title.TextColor3 = Color3.fromRGB(239, 68, 68)
title.Font = Enum.Font.GothamBold
title.TextSize = 20

local input = Instance.new("TextBox", box)
input.Size = UDim2.new(0, 260, 0, 40)
input.Position = UDim2.new(0.5, -130, 0, 60)
input.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
input.PlaceholderText = "Type key here..."
input.Text = ""
input.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

local btn = Instance.new("TextButton", box)
btn.Size = UDim2.new(0, 260, 0, 40)
btn.Position = UDim2.new(0.5, -130, 0, 115)
btn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
btn.Text = "SUBMIT"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    local key = string.gsub(input.Text, "^%s*(.-)%s*$", "%1")
    btn.Text = "CHECKING..."
    if AttemptExecute(key) then
        pcall(function() writefile("MuzeKey.txt", key) end)
        gui:Destroy()
    else
        btn.Text = "INVALID KEY"
        btn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        task.delay(1.5, function()
            btn.Text = "SUBMIT"
            btn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
        end)
    end
end)
