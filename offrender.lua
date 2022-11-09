
--[[ Library Variables ]]--
repeat wait() until game:IsLoaded()
for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do 
v:Disable()
end
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
wait(0.5)

--[[ regular script variables]]--
plr = game.Players.LocalPlayer 
task.spawn(function()
    while true do wait(0.1)
        pcall(function()
            char = plr.Character or plr.CharacterAdded:Wait()
        end)
    end
end)
--[[ next we define
@rs = replicatedStorage
@ts = tweenservice
@ws = workspace
@hs = httpservice
]]--

rs = game.ReplicatedStorage
ts = game:GetService("TweenService")
ws = game.Workspace
hs = game:GetService("HttpService")
--[[ save config vars]]--
if not isfolder("offrender") then 
    makefolder("offrender") 
end 

if not isfolder("offrender/"..plr.Name) then 
    makefolder("offrender/"..plr.Name)
end
if not isfile("offrender/"..plr.Name.."/dungeonsettings.txt") then
    st = {
        farmid = "",
        chestid = "",
        keepchest = false,
        dungeonfarm = false, 
        savedspeed = 60,
        rarity = 1,
        mold = 1,
        url = "",
        sendwebhook = false,
        fps = 5,
        cap = false,
        tweenchest = false,
        onetap = false,
        addsoul = false,
        pingifnewsword = false,
    }
    writefile("offrender/"..plr.Name.."/dungeonsettings.txt",hs:JSONEncode(st))
end
if not isfile("offrender/"..plr.Name.."/newswordids.txt") then 
    writefile("offrender/"..plr.Name.."/newswordids.txt","")
end
writefile("offrender/"..plr.Name.."/totalgems.txt",plr.PlayerGui.MainGui.TopHolder.Gems.Price.Text:gsub("%p",""))
writefile("offrender/"..plr.Name.."/totalimp.txt",plr.PlayerGui.MainGui.ArtifactMenu.Holder.Impossible.Amount.Text:gsub("x",""))

st = hs:JSONDecode(readfile("offrender/"..plr.Name.."/dungeonsettings.txt"))
--[[ Creating a Window]]--
local Window = Library:CreateWindow({
    Title = 'Sword Factory X',
    Center = true, 
    AutoShow = true,
})

--[[ Creating the tabs]]--
local Tabs = {
    -- Creates a new tab titled Main
    Main = Window:AddTab('Main'),
    Web = Window:AddTab("Webhook"),
    Ench = Window:AddTab("Re-Enchanter"),
    Gift = Window:AddTab("Gifts"),
    Boost = Window:AddTab("Boosts"),
    Set = Window:AddTab("Settings"),
}

--[[ Section for autofarm ]]--
autofarm = Tabs.Main:AddLeftGroupbox("[Autofarm]")
autofarmset = Tabs.Main:AddLeftGroupbox("[Other Autofarm Options]")
misc = Tabs.Main:AddLeftGroupbox("[Misc]")

autofarm:AddToggle("dfarm",{
    Text = "Dungeon Farm Toggle",
    Default = st.dungeonfarm,
    Tooltip = "Enable or Disable Dungeon Farm Toggle"
})
autofarmset:AddToggle("keeptoggle",{
    Text = "Keep Chestfinder+?",
    Default = st.keepchest,
    Tooltip = "will keep chestfinder+ swords u get from dungions"
})
autofarmset:AddToggle("tweenc",{
    Text = "Tween to Chests",
    Default = st.tweenchest, 
    Tooltip = "this will tween rather than tp to chests\nless kicks, may miss chests tho (fixing later)",
})
autofarmset:AddToggle('instakill',{
    Text = "One Tap Boss",
    Default = st.onetap, 
    Tooltip = "Note: This feature is inconsistent, but it will not break the script, I recommend it."
})
misc:AddToggle('add',{
    Text = 'Auto add souls',
    Default = st.addsoul,
    Tooltip = "this will auto add souls at 1 second intervals"
})
Toggles.add:OnChanged(function()
    st.addsoul = Toggles.add.Value
end)
Toggles.instakill:OnChanged(function()
    st.onetap = Toggles.instakill.Value 
end)
Toggles.tweenc:OnChanged(function()
    st.tweenchest = Toggles.tweenc.Value 
end)
Toggles.dfarm:OnChanged(function()
    st.dungeonfarm = Toggles.dfarm.Value
end)
Toggles.keeptoggle:OnChanged(function()
    st.keepchest = Toggles.keeptoggle.Value
end)

--[[ Section for settings ]]--
settings = Tabs.Main:AddRightGroupbox("[Settings]")
registerfarm = settings:AddButton("Register Farm Sword",function()
    if char:FindFirstChild("Sword") ~= nil then 
        st.farmid = char.Sword.Config.ITEMID.Value
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Success!",
            Text = "ID: "..st.farmid,
        })
    end 
end)
registerchest = settings:AddButton("Register Chest Sword",function()
    if char:FindFirstChild("Sword") ~= nil then 
        st.chestid = char.Sword.Config.ITEMID.Value 
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Success!",
            Text = "ID: "..st.chestid,
        })
    end 
end)
settings:AddDivider()
settings:AddSlider("tspeed",{
    Text = "Tween Speed",
    Default = st.savedspeed,
    Min = 1,
    Max = 1000,
    Rounding = 0
})

Options.tspeed:OnChanged(function()
    st.savedspeed = Options.tspeed.Value
end)

registerfarm:AddTooltip("press this holding sword out to register (farm)")
registerchest:AddTooltip("press this holding sword out to register (chest)")
--[[ Section for dropdowns]]--
--[[dropdown section vars]]--
moldTable = {}
for i,v in pairs(require(rs.SharedLibrary.Molds).List) do 
    if v.Name ~= "Wood" and v.Name ~= "Unknown" then 
        table.insert(moldTable,v.Name)
    end
end 
rarityTable = {}
for i,v in pairs(require(rs.SharedLibrary.Rarities).List) do
    if v.Name ~= "Basic-" and v.Name ~= "None" then 
        table.insert(rarityTable,v.Name)
    end
end
EnchantTable = {}
for i,v in pairs(require(rs.SharedLibrary.Enchants).List) do
    if not table.find(EnchantTable,v.Name) and v.Chance ~= math.huge then
        table.insert(EnchantTable,v.Name)
    end
end
dropdowns = Tabs.Main:AddRightGroupbox("[Dropdowns]")

dropdowns:AddDropdown('rarity', {
    Values = rarityTable,
    Default = rs.Rarities[st.rarity].RarityName.Value, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = 'Rarity Selected: ',
    Tooltip = 'keeps this rarity and above', -- Information shown when you hover over the textbox
})

dropdowns:AddDropdown('mold', {
    Values = moldTable,
    Default = rs.AllMolds[st.mold].MoldName.Value, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = 'Mold Selected: ',
    Tooltip = 'keeps this mold and above', -- Information shown when you hover over the textbox
})


Options.rarity:OnChanged(function()
    st.rarity = table.find(rarityTable,Options.rarity.Value)
end)

Options.mold:OnChanged(function()
    st.mold = table.find(moldTable,Options.mold.Value)
end)

--[[ end of dropdowns section]]--

--[[ start of webhook tab]]--
webst = Tabs.Web:AddRightGroupbox("[URL & ID]")
webtoggle = Tabs.Web:AddLeftGroupbox("[Toggles]")

webst:AddInput("url",{
    Default = st.url,
    Numeric = false,
    Finished = true,
    Text = "Webhook URL",
    Tooltip = "Input webhook url here for a cookie (my fat juicy cock)",
})

Options.url:OnChanged(function()
    st.url = tostring(Options.url.Value)
end)

-- seperation thign

webtoggle:AddToggle("sendweb",{
    Text = "Send Dungeon Summary",
    Default = st.sendwebhook,
    Tooltip = 'this sends a dungeon summary its sexy use it ok mommy?'
})
webtoggle:AddToggle('ping',{
    Text = "Ping on new item",
    Default = st.pingifnewsword,
    Tooltip = 'this will ping you when you get a new sword (it will ping again if u leave and rejoin and the swords become new',
})
Toggles.ping:OnChanged(function()
    st.pingifnewsword = Toggles.ping.Value
end)
Toggles.sendweb:OnChanged(function()
    st.sendwebhook = Toggles.sendweb.Value
end)   





--[[ start of re enchanter tab!!!!]]--
run = game:GetService("RunService")
tolock = {}
toget = {}
est = Tabs.Ench:AddRightGroupbox("Settings")
et = Tabs.Ench:AddLeftGroupbox("Toggles")
-- ENCAHNT TOGGLES SECTION 
et:AddToggle('enchant',{
    Text = "Start Re-Encahnting",
    Default = false,
    Tooltip = "This will start re enchanting :scream: "
})
Toggles.enchant:OnChanged(function()
    enchanttoggle = Toggles.enchant.Value
end)
-- ENCHANT SETTINGS SECTION
est:AddDropdown('enchmode',{
    Values = {'One Enchant','Two Enchants','Multiple Enchants'},
    Default = 1,
    Multi = false, 
    Text = "Select enchant mode",
    Tooltip = "Enchant mode (see yt video for more info)",
})
est:AddDivider()
est:AddDivider()
Options.enchmode:OnChanged(function()
    mode = tostring(Options.enchmode.Value)
end)
est:AddDropdown('lock',{
    Values = EnchantTable,
    Default = 1,
    Multi = true,
    Text = 'Select Enchants (Lock)',
    Tooltip = 'ONLY USE THIS FOR TWO AND MULTIPLE ENCHANTS'
})
est:AddButton('Check Enchants (Lock)',function()
    warn(table.concat(tolock,"\n"))
end)
est:AddButton('Clear Selected Lock',function()
    tolock = {}
    for i,v in pairs(EnchantTable) do 
        task.wait()
        Options.lock:SetValue({
            v = false,
        })
    end
end)
-- get enchant section
est:AddDivider()
est:AddDivider()

est:AddDropdown('get',{
    Values = EnchantTable, 
    Default = 1,
    Multi = true,
    Text = "Select Enchant (Get)",
    Tooltip = "Use this dropdown for one enchant and the enchant after you get the selected lock one",
})
est:AddButton('Check Enchants (Get)',function()
    warn(table.concat(toget,"\n"))
end)   
est:AddButton("Clear Selected Get",function()
    toget = {}
    for i,v in pairs(EnchantTable) do 
        task.wait()
        Options.get:SetValue({
            v = false,
        })
    end
end)
Options.lock:OnChanged(function()
    tolock = {}
    for i,v in pairs(Options.lock.Value) do 
        table.insert(tolock,i)
    end
end)
Options.get:OnChanged(function()
    toget = {}
    for i,v in pairs(Options.get.Value) do 
        table.insert(toget,i)
    end
end)

--[[end of re enchanter tab!!!!]]--





--[[ start of gifts tab]]--

function findHighestGiftByType(Type,Folder,InfoOnly)
    decodedgifts = hs:JSONDecode(rs.Data[plr.Name].Stats.CurrentGifts.Value) 
    findHighestTable = {}
    for i,v in pairs(decodedgifts) do 
        table.insert(findHighestTable,"ID: "..i..Type..": "..v.Config[Type])
    end 

    high = 0 
    for i,v in pairs(findHighestTable) do 
        es = v:match(Type.."%p%s(%d+)")
        if tonumber(es) > high and tonumber(es) < 500 then 
            high = tonumber(es)
            claim = v:match("ID%p%s(%d+)")
        end
    end
    if not InfoOnly then
        game:GetService("ReplicatedStorage").Framework.RemoteEvent:FireServer(0,"ProductHandler","AcceptGift",{claim})
    end
    if Folder == "Classes" then
        return "Claimed "..Type.." : "..rs[Folder][high][Type.."Names"].Value
    else
        return "Claimed "..Type.." : "..rs[Folder][high][Type.."Name"].Value
    end
end
--[[ start of ui part of gifts tab]]--
settings = Tabs.Gift:AddRightGroupbox("Settings")
claim = Tabs.Gift:AddLeftGroupbox("Buttons")
selectedfolder = "Rarities"
settings:AddDropdown('gifts',{
    Values = {"Rarity","Quality","Class","Mold"},
    Default = 1,
    Multi = false,
    Text = "Find Highest: ",
    Tooltip = "pressing hte claim button will find the highest of what you select here"
})
settings:AddDivider()
settings:AddButton('Gift Amount (Accurate)',function()
    decoded = hs:JSONDecode(rs.Data[plr.Name].Stats.CurrentGifts.Value)
    gifts = 0
    for i,v in pairs(decoded) do 
        gifts = gifts+1
    end
    wait(0.1)
    game.StarterGui:SetCore("SendNotification",{
        Title = "Checking...",
        Text = tostring(gifts),
    })
end)
Options.gifts:OnChanged(function() 
    selectedtype = Options.gifts.Value 
    if selectedtype == "Mold" then 
        selectedfolder = "Molds"
    elseif selectedtype == "Rarity" then 
        selectedfolder = "Rarities"
    elseif selectedtype == "Class" then 
        selectedfolder = "Classes"
    elseif selectedtype == "Quality" then 
        selectedfolder = "Qualities"
    end
end)
claim:AddButton('Get Highest Info',function()
    game.StarterGui:SetCore("SendNotification",{
        Title = "Selected Type: "..selectedtype,
        Text = findHighestGiftByType(tostring(selectedtype),tostring(selectedfolder),true),
    })
end)
claim:AddDivider()
claim:AddButton('Claim',function()
    findHighestGiftByType(tostring(selectedtype),tostring(selectedfolder),false)
end)
claim:AddDivider()
claim:AddButton("Claim Cracked",function()
    decodedgifts = hs:JSONDecode(rs.Data[plr.Name].Stats.CurrentGifts.Value) 
    for i,v in pairs(decodedgifts) do 
        if v.Config.Cracked == true then 
            game:GetService("ReplicatedStorage").Framework.RemoteEvent:FireServer(0,"ProductHandler","AcceptGift",{tostring(i)})
        end
    end
end)
claim:AddDivider()
claim:AddButton("Claim All (Stand still)",function()
    decoded = hs:JSONDecode(rs.Data[plr.Name].Stats.CurrentGifts.Value)
    for i,v in pairs(decoded) do 
        game:GetService("ReplicatedStorage").Framework.RemoteEvent:FireServer(0,"ProductHandler","AcceptGift",{i})
    end
end)
--[[ end of webhook tab]]--
--[[ start of boost tab]]--
boostTab = {}
for i,v in pairs(plr.PlayerGui.MainGui.TopHolder.BoostsHolder:GetChildren()) do 
    if v:IsA("TextLabel") then 
        subbed = v.Name:gsub("Boost","")
        table.insert(boostTab,tostring(subbed))
    end
end
boostset = Tabs.Boost:AddRightGroupbox("Boosts")
boosttogsec = Tabs.Boost:AddLeftGroupbox("Buttons")
boostset:AddDropdown('boost',{
    Values = boostTab,
    Default = 1,
    Multi = false,
    Text = 'select boost to buy',
    Tooltip = 'this selects the amount of boosts to buy',
})
boostset:AddInput('amount',{
    Default = "",
    Numeric = true, 
    Finished = true,
    Text = "amount of boosts to buy",
    Tooltip = "type here the amount of boosts u wanna buy (only numbers)",
})
Options.boost:OnChanged(function()
    boostwanted = Options.boost.Value
end)
Options.amount:OnChanged(function()
    boostswanted = Options.amount.Value
end)
-- a
boosttogsec:AddButton('Buy',function()
    runservice = game:GetService("RunService")
    local connection 
    counter = 0
    function Buy()
        print('hi')
        if counter < tonumber(boostswanted) then 
            counter = counter+1
            rs.Framework.RemoteFunction:InvokeServer(0,"BoostService","BuyWithGems",{tostring(boostwanted),"30Min"})
        else
            connection:Disconnect()
        end
    end
    connection = runservice.Heartbeat:Connect(Buy)
end)
boosttogsec:AddDivider()
boosttogsec:AddButton('Use',function()
    runservice = game:GetService("RunService")
    local connection 
    counter = 0
    function Use()
        print('hi')
        if counter < tonumber(boostswanted) then 
            counter = counter+1
            rs.Framework.RemoteFunction:InvokeServer(0,"BoostService","Use",{tostring(boostwanted),"30Min"})
        else
            connection:Disconnect()
        end
    end
    connection = runservice.Heartbeat:Connect(Use)
end)

--[[ start of settings tab]]
perf = Tabs.Set:AddLeftGroupbox("[Performance Settings]")
config = Tabs.Set:AddRightGroupbox("[Save Config]")

perf:AddSlider("slidefps",{
    Text =  "Selected FPS",
    Default = st.fps,
    Min = 5,
    Max = 60,
    Rounding = 0
})
Options.slidefps:OnChanged(function()
    st.fps = Options.slidefps.Value
end)

perf:AddToggle('cap',{
    Text = "Cap FPS at selected fps",
    Default = st.cap,
    Tooltip = 'this will cap fps at what u have selected on slider',
})

Toggles.cap:OnChanged(function()
    st.cap = Toggles.cap.Value 
end)

config:AddButton('Save Config',function()
    writefile('offrender/'..plr.Name.."/dungeonsettings.txt",hs:JSONEncode(st))
end)
config:AddDivider()
config:AddButton('Reset Current Config',function()
    st = {
        farmid = "",
        chestid = "",
        keepchest = false,
        dungeonfarm = false, 
        savedspeed = 60,
        rarity = 1,
        mold = 1,
        url = "",
        sendwebhook = false,
        fps = 5,
        cap = false,
        tweenchest = false,
        onetap = false,
        addsoul = false,
        pingifnewsword = false,
    }
    writefile('offrender/'..plr.Name.."/dungeonsettings.txt",hs:JSONEncode(st))
end)
--[[ all function s for dungion farm]] -- 
--[[ 
    Auto Drop Check Enchant
    This is for keeping Chestfinder+ swords.
]]--
_G.autoswing = false
function Chestfinder(a)
    if st.keepchest then
        for i,v in pairs(a:GetChildren()) do 
            for i = 1,4 do 
                if v.Name == "Enchant"..i then 
                    if v.Value:find("Chestfinder%+") then 
                        return true 
                    end
                end
            end 
        end 
    end 
end 
--[[ checking the timer]]-- 
function checkTimeApart(startedtime,glort)
    print(tick()-startedtime)
    if tick()-startedtime >= glort then 
        return true 
    end
end
dropping = false 
function AutoDrop()
    dropping = true
    char.Humanoid:UnequipTools() -- make sure every sword is in backpackw
    wait(0.2) -- wait a lil bit
    for i,v in pairs(plr.Backpack:GetChildren()) do -- loop through backpack
        if v:FindFirstChild("Config") and v.Config:FindFirstChild("Rarity") and v.Config:FindFirstChild("ITEMID") and v.Config:FindFirstChild("Mold") and v.Config:FindFirstChild("Cracked") then 
            if v.Config.Mold.Value >= st.mold and v.Config.Cracked.value == true then -- if  mold is above selected mold and is cracked then
            else  -- if its not then
                if v.Config.Rarity.Value < st.rarity then -- if swords rarity is less than rarity filter
                    if v.Config.ITEMID.Value ~= st.farmid and v.Config.ITEMID.Value ~= st.chestid then -- and its not a farm sword then
                        if not Chestfinder(v.Config) then  -- if it doesnt have chestfinder+ then
                            char.Humanoid:EquipTool(v) -- equip sword
                            rs.Framework.RemoteEvent:FireServer(0,"BackpackServer","Drop",{}) -- drop sword
                        end 
                    end
                end
            end
        end
    end
    dropping = false
end 
--[[
    Enter Graveyard Function:
    This will provide a more reusable function.
]]--

function enterGraveyard()
    if ws:FindFirstChild("HalloweenTower") == nil then 
        if ws.Maps:FindFirstChild("Graveyard") ~= nil then -- if graveyard exists then 
            if ws.Maps:FindFirstChild("Graveyard"):FindFirstChild("DungeonMatchmaking"):FindFirstChild("MatchmakingPad") == nil then 
                game:GetService("ReplicatedStorage").Events.ToMap:FireServer(rs.Data[plr.Name].Stats,workspace[plr.Name.."'s Base"],plr.Name,"Graveyard")
            else 
                game:GetService("ReplicatedStorage").Events.ToMap:FireServer(rs.Data[plr.Name].Stats,workspace[plr.Name.."'s Base"],plr.Name,"Graveyard")
            end
        else 
            game:GetService("ReplicatedStorage").Events.ToMap:FireServer(rs.Data[plr.Name].Stats,workspace[plr.Name.."'s Base"],plr.Name,"Graveyard")
            -- ^^ if graveyard doesn't exist then tp to graveyard.]
        end 
    end
end

--[[
    Start Tween Function:
    This will provide with function so there's less repetitive code.
]]-- 

function Tween(Part,ExtraX,ExtraY,ExtraZ)
    DistanceApart = (char.HumanoidRootPart.Position-Part.Position).Magnitude
    Info = TweenInfo.new(DistanceApart/st.savedspeed,Enum.EasingStyle.Linear)
    _G.a = ts:Create(char.HumanoidRootPart,Info,{CFrame = Part.CFrame*CFrame.new(ExtraX,ExtraY,ExtraZ)}) 
    _G.a:Play()
    _G.a.Completed:Wait()
end 
function Comma(amount)
    while true do wait()
        amount,k = string.gsub(amount,"^(-?%d+)(%d%d%d)",'%1,%2')
        if k == 0 then break end
    end
	return amount
end

--[[
    Start Auto Equip Function
    This will provide a very reusable function.
]]--
function AutoEquip(Farm,Chest) -- whether or not we want to equip chest or farm sword
    for i,v in pairs(plr.Backpack:GetChildren()) do  -- loop through backpack
        if v:FindFirstChild("Config") and v.Config:FindFirstChild("ITEMID") then
            if Farm then 
                if v.Config.ITEMID.Value == st.farmid then 
                    char.Humanoid:EquipTool(v)
                end
            end
            if Chest then 
                if v.Config.ITEMID.Value == st.chestid then 
                    char.Humanoid:EquipTool(v)
                end
            end
        end
    end
end 
--[[ 
    Define function that checks for mobs being alive
]]--
function checkForMobs()
    for i,v in pairs(ws.Mobs:GetChildren()) do 
        if v.Name == "Scarecrow" or v.Name == "Skeleton" or v.Name == "Bimbo the Terrifier" then 
            return true 
        end
    end 
end
--[[ function that will help with loading]]
function findLoadedMobs()
    mobs = 0 
    for i,v in pairs(ws.Mobs:GetChildren()) do 
        if v.Name == "Scarecrow" or v.Name == "Skeleton" then 
            if v:FindFirstChild("HumanoidRootPart") then 
                mobs = mobs+1
            else
            end
        end
        if mobs >= 23 then return true end
    end
end
--[[
    Define a function that returns the nearest mob
]]--
function ClosestMob(table) 
    Closest = 9e9
    for i,v in pairs(table) do 
        if (char.HumanoidRootPart.Position-v.HumanoidRootPart.Position).Magnitude then 
            Distance = (char.HumanoidRootPart.Position-v.HumanoidRootPart.Position).Magnitude 
            if Distance < Closest then 
                Closest = Distance 
                ClosestMobReturned = v 
            end
        end
    end
    return ClosestMobReturned
end 
--[[ fucntion for getting chests cuz i cnat mkae it wokr otherwise cuz im terrible scripter]]--
function getChests(tween)
    if tween then 
        wait(2)
        while true do task.wait()
            _G.chests = {}
            if not ws.Mobs:FindFirstChild("Scarecrow") or ws.Mobs:FindFirstChild("Skeleton") then 
                for names,_ in pairs(require(rs.SharedLibrary.Chests)) do 
                    if ws:FindFirstChild("HalloweenTower") ~= nil then 
                        for i,v in pairs(ws:FindFirstChild("HalloweenTower"):GetDescendants()) do 
                            if v.Name == names then 
                                if v:FindFirstChild("Effect") then
                                    if v:FindFirstChild("Chest_Base").Body:FindFirstChild("Dungeon_Doors") == nil or v:FindFirstChild("Lock") == nil then
                                        table.insert(_G.chests,v)
                                    end 
                                end 
                            end
                        end
                    end
                end
            end
            wait(0.1)
            if #_G.chests == 0 then break end
            tweenclose = 9e9
            for i,v in pairs(_G.chests) do 
                if (char.HumanoidRootPart.Position-v:FindFirstChild("Effect").Position).Magnitude then 
                    tweendist = (char.HumanoidRootPart.Position-v:FindFirstChild("Effect").Position).Magnitude
                    if tweendist < tweenclose then 
                        tweenclose = tweendist 
                        tr = v 
                    end
                end
            end 
            wait(0.01)
            repeat wait()
                nogp = false
                nokeys = false
                task.spawn(function()
                    while true do task.wait()
                        if #_G.chests == 0 then break end 
                        if dropping == false then
                            AutoEquip(false,true)
                        end
                    end 
                end)
                for i,v in pairs(plr.Backpack:GetChildren()) do 
                    if i >= 8 then 
                        AutoDrop()
                    end
                end 
                if tr.Name == "ExtraHallowedChest" then 
                    wait(1)
                    if rs.Data[plr.Name].Stats.ExtraChest.Value == false then 
                        nogp = true 
                    end
                end 
                if tr.Name == "MaliceChest" then 
                    if plr.PlayerGui.MainGui.Inventory:FindFirstChild("Item") == nil then 
                        nokeys = true 
                    end
                end 
                _G.autoswing = true 
                Tween(tr.Effect,1.5,0,0)
                _G.autoswing = false 
                wait(0.1)
                if tr:FindFirstChildWhichIsA("ProximityPrompt",true) then 
                    fireproximityprompt(tr:FindFirstChildWhichIsA("ProximityPrompt",true),100)
                end
                for i,v in pairs(plr.Backpack:GetChildren()) do 
                    if i >= 8 then 
                        AutoDrop()
                    end
                end 
            until tr:FindFirstChild("Chest_Base").Body:FindFirstChild("Dungeon_Doors") ~= nil or tr:FindFirstChild("Lock") == nil or ws:FindFirstChild("HalloweenTower") == nil or nokeys == true or nogp == true
            tr.Name = "collected"
        end
    else
        if not ws.Mobs:FindFirstChild("Scarecrow") or ws.Mobs:FindFirstChild("Skeleton") then 
            for names,_ in pairs(require(rs.SharedLibrary.Chests)) do 
                if ws:FindFirstChild("HalloweenTower") ~= nil then
                    for i,v in pairs(ws:FindFirstChild("HalloweenTower"):GetDescendants()) do 
                        if v.Name == names then 
                            if v:FindFirstChild("Chest_Base").Body:FindFirstChild("Dungeon_Doors") == nil or v:FindFirstChild("Lock") == nil then 
                                nokeys = false
                                nogp = false
                                repeat wait()
                                    for i,v in pairs(plr.Backpack:GetChildren()) do 
                                        if i >= 8 then 
                                            AutoDrop()
                                        end
                                    end
                                    if v.Name == "MaliceChest" then 
                                        if plr.PlayerGui.MainGui.Inventory.Holder:FindFirstChild("Item") == nil then 
                                            nokeys = true 
                                        end 
                                    end
                                    if v.Name == "ExtraHallowedChest" then 
                                        if rs.Data[plr.Name].Stats.ExtraChest.Value == false then 
                                            nogp = true 
                                        end
                                    end 
                                    if char:FindFirstChild("Sword") then 
                                        if char:FindFirstChild("Sword").Config.ITEMID.Value ~= st.chestid then 
                                            AutoEquip(false,true)
                                        end
                                    else
                                        AutoEquip(false,true)
                                    end
                                    if st.tweenchest then 
                                        if v:FindFirstChild("Effect") then
                                            Tween(v.Effect)
                                        else
                                        end
                                    else
                                        if v:FindFirstChild("Effect") then
                                            if (char.HumanoidRootPart.Position-v.Effect.Position).Magnitude <= 1000 then 
                                                char.HumanoidRootPart.CFrame = v.Effect.CFrame 
                                            else
                                                warn 'farm died'
                                            end
                                        else
                                        end
                                    end 
                                    AutoEquip(false,true)
                                    if v:FindFirstChildWhichIsA("ProximityPrompt",true) then 
                                        fireproximityprompt(v:FindFirstChildWhichIsA("ProximityPrompt",true),100)
                                    end
                                    if char:FindFirstChild("Sword") == nil then 
                                    else
                                        char.Sword:Activate()
                                    end 
                                until v:FindFirstChild("Chest_Base").Body:FindFirstChild("Dungeon_Doors") ~= nil or v:FindFirstChild("Lock") ~= nil or nokeys or nogp or ws:FindFirstChild("HalloweenTower") == nil
                                for i,v in pairs(plr.Backpack:GetChildren()) do 
                                    if i >= 8 then 
                                        AutoDrop()
                                    end
                                end
                            end 
                        end 
                    end 
                end
            end
        else 
            rs.Framework.RemoteEvent:FireServer(0,"UIServer","Teleport",{})
        end
    end
end
--[[ function that finds the nearest chest ( for tween to chests)]]--
--[[ start of the actual toggles farming]]--
spawn(function()
    while true do wait()
        if st.dungeonfarm then 
            _G.autoswing = false
            pcall(function()
                if ws:FindFirstChild("HalloweenTower") == nil then
                    breaktimer = true
                    if game.Players.LocalPlayer.PlayerGui.MainGui:FindFirstChild("DungeonSummary") then
                        game.Players.LocalPlayer.PlayerGui.MainGui.DungeonSummary:Destroy()
                    end
                    AutoEquip(true,false)
                    ws.Gravity = 0
                    enterGraveyard()
                    wait(2)
                    AutoDrop()
                    AutoEquip(true,false)
                    repeat wait() 
                        if ws:FindFirstChild("HalloweenTower") == nil then 
                            if ws.Maps.Graveyard.Brick.BillboardGui.Counter.Visible == false then
                                if (char.HumanoidRootPart.Position-ws.Maps.Graveyard.DungeonMatchmaking.MatchmakingPad.Position).Magnitude >= 35 then
                                    _G.autoswing = true
                                    Tween(ws.Maps.Graveyard.DungeonMatchmaking.MatchmakingPad,0,5,0)
                                else 
                                    ws.Gravity = 198 -- set gravity back to normal when near pad 
                                    _G.autoswing = false
                                end
                            end
                        end
                    until ws:FindFirstChild("HalloweenTower") ~= nil 
                    repeat wait() until ws.CurrentCamera.CameraType == Enum.CameraType.Scriptable -- wait until cutscene is active
                    repeat wait() until ws.CurrentCamera.CameraType == Enum.CameraType.Custom -- wait until cutscene is over
                    repeat wait() until findLoadedMobs() -- wait 5 seconds to give mobs to do load
                    breaktimer = false
                    startedTime = tick()
                    if ws:FindFirstChild("HalloweenTower") then 
                        spawn(function()
                            while true do task.wait(0.5)
                                if breaktimer then break end
                                if checkTimeApart(startedTime,120) then 
                                    rs.Framework.RemoteEvent:FireServer(0,"UIServer","Teleport",{})
                                    _G.a:Cancel()
                                end
                            end
                        end)
                    end 
                end
                nohumanoidrootpart = false
                    while wait() do -- start a loop
                        mobs = {} -- define a table ( mobs will go here)!
                        for i,v in pairs(ws.Mobs:GetChildren()) do -- loop through mob folder
                            if v.Name == "Skeleton" or v.Name == "Scarecrow" then -- if dungeon mob name then 
                                if v:FindFirstChild("HumanoidRootPart") then -- if the mob has a humanoidrootpart then 
                                    table.insert(mobs,v) -- insert mob instance to table
                                end
                            end
                        end 
                        wait(0.1) -- give a bit of time
                        --[[
                            Find closest mob under here
                        ]]--
                        m = ClosestMob(mobs)
                        repeat wait()
                            if m:FindFirstChild("HumanoidRootPart") then 
                                _G.autoswing = true
                                Tween(m:FindFirstChild("HumanoidRootPart"),0,1,-2)
                                if m:FindFirstChild("Humanoid") == nil or m:FindFirstChild("Humanoid").Health == 0 then m:Destroy() end
                            else nohumanoidrootpart = true
                            end
                        until m == nil or m:FindFirstChild("Humanoid") == nil or m:FindFirstChild("Humanoid").Health == 0 or ws:FindFirstChild("HalloweenTower") == nil or nohumanoidrootpart
                        if ws:FindFirstChild("HalloweenTower") == nil then break end 
                        nohumanoidrootpart = false
                        if not checkForMobs() then 
                            checkAgain = true 
                            endrepeat = false
                        end
                        if checkAgain == true then 
                            checkTimer = tick()
                            repeat if checkForMobs() then endrepeat = true else endrepeat = false end wait() until endrepeat == true or tick()-checkTimer >= 2 
                            if not endrepeat then break end 
                        end 
                    end 
                    _G.autoswing = false
                    wait(1)
                    if ws:FindFirstChild("HalloweenTower") then 
                        char.HumanoidRootPart.CFrame = ws:FindFirstChild("HalloweenTower").EndModule.Parts.PlayerEnterTrigger.CFrame
                    end
                    wait(1.5)
                    while true do wait()
                        for _,v in pairs(ws.Mobs:GetChildren()) do  -- loop through mob table
                            if v.Name == "Bimbo the Terrifier" then  -- if find the boss 
                                if v:FindFirstChild("HumanoidRootPart") then -- if the boss has an humanoidrootpart
                                    repeat wait(0.1) -- repeat 
                                        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
                                            if v:FindFirstChild("Humanoid") ~= nil then 
                                                if st.onetap then
                                                    v.Humanoid.Health = 0   
                                                end
                                                Tween(v.HumanoidRootPart,0,3,2.5)
                                            end 
                                        else 
                                        end
                                        _G.autoswing = true
                                    until not checkForMobs() or v:FindFirstChild("Humanoid") == nil or v:FindFirstChild("Humanoid").Health <= 0 or ws:FindFirstChild("HalloweenTower") == nil-- until no mobs exist
                                else 
                                end 
                                if ws:FindFirstChild("HalloweenTower") == nil then break end
                            end
                        end
                    if not checkForMobs() then break end 
                end 
                _G.autoswing = false
                char.HumanoidRootPart.CFrame = ws:FindFirstChild("HalloweenTower").EndModule.Parts.GateBlock.CFrame
                getChests(st.tweenchest)
                wait(0.5)
                AutoDrop()
                wait(0.1)
                char.HumanoidRootPart.CFrame = ws:FindFirstChild("HalloweenTower").EndModule.Parts.FinalBossSpawn.CFrame
                wait(0.5)
                AutoEquip(true,false)
                if ws:FindFirstChild("HalloweenTower") ~= nil then
                    for i,v in pairs(ws:FindFirstChild("HalloweenTower").EndModule.Parts.Stands:GetChildren()) do 
                        if v:FindFirstChildWhichIsA("TextLabel",true).Text == plr.Name then 
                            _G.autoswing = true
                            Tween(v:FindFirstChild("Pad",true),0,1.5,0)
                            wait(0.1)
                            _G.autoswing = false
                        end
                    end
                end 
                wait(0.1)
                writefile("offrender/"..plr.Name.."/totalgems.txt",plr.PlayerGui.MainGui.TopHolder.Gems.Price.Text:gsub("%p",""))
                writefile("offrender/"..plr.Name.."/totalimp.txt",plr.PlayerGui.MainGui.ArtifactMenu.Holder.Impossible.Amount.Text:gsub("x",""))
                dungeonDone = true 
                wait(0.1)
                dungeonDone = false
                rs.Framework.RemoteEvent:FireServer(0,"UIServer","Teleport",{})
                repeat wait() until workspace:FindFirstChild("HalloweenTower") == nil
                breaktimer = true
            end)
        end
    end
end)
plrdata = rs.Data[plr.Name]
GemsOnExecution = plr.PlayerGui.MainGui.TopHolder.Gems.Price.Text:gsub("%p","")
CandyOnExecution = plr.PlayerGui.MainGui.Shop.Holder.Candy.CandyAmount.Amount.Text:gsub("%D","")
spawn(function()
    while true do wait()
        if st.sendwebhook and dungeonDone then 
            gained = plr.PlayerGui.MainGui.TopHolder.Gems.Price.Text:gsub("%p","")-GemsOnExecution
            cgained = tonumber(plr.PlayerGui.MainGui.Shop.Holder.Candy.CandyAmount.Amount.Text:gsub("%D","")-CandyOnExecution)
            playerInfo = {}
            dungeonInfo = {}
            swordInfo = {}
            allAccountInfo = {}
            table.insert(playerInfo,"Username: "..plr.Name)
            table.insert(playerInfo,"Gems: "..plr.PlayerGui.MainGui.TopHolder.Gems.Price.Text)
            table.insert(playerInfo,"Gems Gained: +"..Comma(gained))
            table.insert(playerInfo,"Candy: "..plr.PlayerGui.MainGui.Shop.Holder.Candy.CandyAmount.Amount.Text)
            table.insert(playerInfo,"Candy Gained:  +"..cgained)
            table.insert(dungeonInfo,"Last Dungeon Run Time: "..plrdata.Stats.FastestDungeonRun.Value/1000)
            table.insert(dungeonInfo,"Total Dungeons Completed: "..plrdata.Stats.DungeonsCompleted.Value)
            table.insert(playerInfo,"------\nArtifacts:\n------")
            for i,v in pairs(plr.PlayerGui.MainGui.ArtifactMenu.Holder:GetChildren()) do 
                if v.Name == "Common" or  v.Name == "Rare" or v.Name == "Epic" or v.Name == "Legendary" or v.Name == "Impossible" then 
                    table.insert(playerInfo,v.Name..": "..v:FindFirstChild("Amount").Text:gsub("x",""))
                end
            end
            string = readfile("offrender/"..plr.Name.."/newswordids.txt")
            for i,v in pairs(plr.Backpack:GetChildren()) do 
                if v:FindFirstChild("Config") and v.Config:FindFirstChild("Rarity") and v.Config:FindFirstChild("Mold") and v.Config:FindFirstChild("Cracked") and v.Config:FindFirstChild("ITEMID") and v.Config:FindFirstChild("Class") then 
                    if v.Config.ITEMID.Value ~= st.chestid and v.Config.ITEMID.Value ~= st.farmid then 
                        if v.Config.Mold.Value >= st.mold and v.Config.Cracked.Value == true or v.Config.Rarity.Value >= st.rarity then 
                            if v.Config.Class.Value > 0 then 
                                v.Config.Class.Value = 0
                                if not string:find(tostring(v.Config.ITEMID.Value)) then
                                    appendfile("offrender/"..plr.Name.."/newswordids.txt",tostring(v.Config.ITEMID.Value)..",")
                                    table.insert(swordInfo,"Rarity: "..rs.Rarities[v.Config.Rarity.Value].RarityName.Value.." | ".."Quality: "..rs.Qualities[v.Config.Quality.Value].QualityName.Value.." | ".."Mold: "..rs.AllMolds[v.Config.Mold.Value].MoldName.Value.." | ".."Cracked: "..tostring(v.Config.Cracked.Value))
                                end
                            end
                        end
                    end
                end
            end 
            if #swordInfo == 0 then
                a = ""
                table.insert(swordInfo,"No New Swords")
            else
                if st.pingifnewsword then
                    a = "@everyone"
                else
                    a = ""
                end
            end
            totalGems = 0
            totalImps = 0
            for i,v in pairs(listfiles("offrender")) do 
                for _,k in pairs(listfiles(v)) do 
                    if k:find("totalgems") then 
                        totalGems = totalGems+readfile(k)
                    end
                    if k:find("totalimp") then 
                        totalImps = totalImps+readfile(k)
                    end
                end
            end
            table.insert(allAccountInfo,"Gems Accross All Accounts: "..Comma(totalGems))
            table.insert(allAccountInfo,"Impossibles Accross All Accounts: "..totalImps)
            local data =
            {
            ["content"] = a,
            ["embeds"] = {{
                ["title"] = "OwO :blush: :pleading_face:",
                ["description"] = "",
                ["type"] = "rich",
                ["color"] = tonumber(0x000000),
                ["fields"] = {
                            {
                                ["name"] = "Player Info:",
                                ["value"] = "```"..table.concat(playerInfo,"\n\n").."```",
                                ["inline"] = false
                            },
                            {
                                ["name"] = "Dungeon Info:",
                                ["value"] = "```"..table.concat(dungeonInfo,"\n\n").."```",
                                ["inline"] = false
                            },
                            {
                                ["name"] = "Swords (New Only):",
                                ["value"] = "```"..table.concat(swordInfo,"\n\n").."```",
                                ["inline"] = false
                            },
                            {
                                ["name"] = "All Accounts:",
                                ["value"] = "```"..table.concat(allAccountInfo,"\n\n").."```",
                                ["inline"] = false
                            },
                        }
                    }}
                }
            local body = game:GetService("HttpService"):JSONEncode(data)
                                                                            
            local headers = {["content-type"] = "application/json"}
            request = http_request or request or HttpPost or syn.request or http.request
            local msg = {Url = st.url, Body = body, Method = "POST", Headers = headers}
            request(msg)
            wait(3)
        end
    end
end)
spawn(function()
    while true do wait()
        if st.cap then 
            setfpscap(st.fps)
        else
            setfpscap(120)
        end
    end
end)
spawn(function()
    while true do wait()
        if st.addsoul then 
            rs.Framework.RemoteFunction:InvokeServer(0,"SoulTankService","AddSouls",{})
            wait(1)
        end
    end 
end)
spawn(function()
    while true do wait()
        if _G.autoswing then
            pcall(function()
                if not dropping then
                    if char:FindFirstChild("Sword") then 
                        char.Sword:Activate()
                        if char.Sword.Config.ITEMID.Value ~= st.farmid then 
                            AutoEquip(true,false)
                        end 
                    else
                        AutoEquip(true,false)
                    end 
                end
            end)
        end
    end
end)
-- auto enchanter rewritten baby
enchanting = false
task.spawn(function()
    while true do wait()
        pcall(function()
            enchanting = false
            aei = workspace[plr.Name.."'s Base"].Enchanter.Item.Value.Config
            if enchanttoggle and not enchanting then
                if mode == "One Enchant" then 
                        while enchanttoggle do wait()
                            enchanting = true 
                            if enchanttoggle then
                                e1 = aei.Enchant1.Value:split('"')
                                e2 = aei.Enchant2.Value:split('"')
                                e3 = aei.Enchant3.Value:split('"')
                                e4 = aei.Enchant4.Value:split('"')
                                if table.find(toget,e1[2]) or table.find(toget,e2[2]) or table.find(toget,e3[2]) or table.find(toget,e4[2]) then 
                                    Toggles.enchant:SetValue(false)
                                else
                                    if enchanttoggle then
                                        game.ReplicatedStorage.Framework.RemoteFunction:InvokeServer(0,"EnchanterServer","Buy",{})
                                
                                    end
                                end
                            end
                        end
                end 
                if mode == "Two Enchants" then 
                        while enchanttoggle do wait()
                            if enchanttoggle then
                                enchanting = true 
                                locked = false
                                repeat wait() 
                                    e1 = aei.Enchant1.Value:split('"')
                                    e2 = aei.Enchant2.Value:split('"')
                                    e3 = aei.Enchant3.Value:split('"')
                                    e4 = aei.Enchant4.Value:split('"')
                                    if table.find(tolock,e1[2]) then 
                                        locked = true 
                                        lock = 1 
                                    end
                                    if table.find(tolock,e2[2]) then 
                                        locked = true
                                        lock = 2
                                    end 
                                    if table.find(tolock,e3[2]) then 
                                        locked = true 
                                        lock = 3 
                                    end
                                    if table.find(tolock,e4[2]) then 
                                        locked = true 
                                        lock = 4 
                                    end
                                    if not locked then 
                                        game.ReplicatedStorage.Framework.RemoteFunction:InvokeServer(0,"EnchanterServer","Buy",{})
                                    end
                                until locked == true or not enchanttoggle 
                            end
                            if enchanttoggle then
                            counter = 0 
                            run = game:GetService("RunService")
                            local connection
                            function buyLocks()
                                if counter >= 50 then 
                                    connection:Disconnect()
                                else
                                    counter = counter+1
                                    game.ReplicatedStorage.Framework.RemoteFunction:InvokeServer(0,"EnchanterServer","BuyLock",{}) 
                                end 
                            end
                            connection = run.Heartbeat:Connect(buyLocks)
                            wait(0.1)
                            game.ReplicatedStorage.Framework.RemoteFunction:InvokeServer(0,"EnchanterServer","ApplyLocks",{lock,50})
                            -- apply lock remote 
                            gotten = false
                            repeat wait()
                                e1 = aei.Enchant1.Value:split('"')
                                e2 = aei.Enchant2.Value:split('"')
                                e3 = aei.Enchant3.Value:split('"')
                                e4 = aei.Enchant4.Value:split('"')
                                if table.find(toget,e1[2]) then 
                                    gotten = true 
                                end
                                if table.find(toget,e2[2]) then 
                                    gotten = true 
                                end
                                if table.find(toget,e3[2]) then 
                                    gotten = true 
                                end
                                if table.find(toget,e4[2]) then 
                                    gotten = true 
                                end
                                if not gotten and aei.EnchantLock.Value ~= "[]" then 
                                    rs.Framework.RemoteFunction:InvokeServer(0,"EnchanterServer","Buy",{})
                                end
                            until gotten or aei.EnchantLock.Value == "[]" or not enchanttoggle
                            if gotten then Toggles.enchant:SetValue(false) end
                        end
                        end
                    
                end
                if mode == "Multiple Enchants" then
                    locked = false
                        while enchanttoggle do wait()
                                enchanting = true 
                                if enchanttoggle then
                                    repeat wait() 
                                        e1 = aei.Enchant1.Value:split('"')
                                        e2 = aei.Enchant2.Value:split('"')
                                        e3 = aei.Enchant3.Value:split('"')
                                        e4 = aei.Enchant4.Value:split('"')
                                        if table.find(tolock,e1[2]) then 
                                            locked = true 
                                            lock = 1 
                                        end
                                        if table.find(tolock,e2[2]) then 
                                            locked = true
                                            lock = 2
                                        end 
                                        if table.find(tolock,e3[2]) then 
                                            locked = true 
                                            lock = 3 
                                        end
                                        if table.find(tolock,e4[2]) then 
                                            locked = true 
                                            lock = 4 
                                        end
                                        if not locked then 
                                            game.ReplicatedStorage.Framework.RemoteFunction:InvokeServer(0,"EnchanterServer","Buy",{})
                                        end
                                    until locked == true or not enchanttoggle
                                end 
                            if enchanttoggle then
                                counter = 0 
                                run = game:GetService("RunService")
                                local connection
                                function buyLocks()
                                    if counter >= 50 then 
                                        connection:Disconnect()
                                    else
                                        counter = counter+1
                                        game.ReplicatedStorage.Framework.RemoteFunction:InvokeServer(0,"EnchanterServer","BuyLock",{}) 
                                    end 
                                end
                                connection = run.Heartbeat:Connect(buyLocks)
                                wait(0.1)
                                game.ReplicatedStorage.Framework.RemoteFunction:InvokeServer(0,"EnchanterServer","ApplyLocks",{lock,50})
                                -- apply lock remote 
                                gotten = false
                                repeat wait()
                                    matches = 0
                                    e1 = aei.Enchant1.Value:split('"')
                                    e2 = aei.Enchant2.Value:split('"')
                                    e3 = aei.Enchant3.Value:split('"')
                                    e4 = aei.Enchant4.Value:split('"')
                                    if table.find(toget,e1[2]) then 
                                        matches = matches+1
                                    end
                                    if table.find(toget,e2[2]) then 
                                        matches = matches+1
                                    end
                                    if table.find(toget,e3[2]) then 
                                        matches = matches+1
                                    end
                                    if table.find(toget,e4[2]) then 
                                        matches = matches+1
                                    end
                                    if matches == #toget then 
                                        gotten = true 
                                    end
                                    if not gotten and aei.EnchantLock.Value ~= "[]" then 
                                        rs.Framework.RemoteFunction:InvokeServer(0,"EnchanterServer","Buy",{})
                                    end
                                until gotten or aei.EnchantLock.Value == "[]" or not enchanttoggle
                                if gotten then Toggles.enchant:SetValue(false) end
                            end
                            end
                        
                end
            end
        end)
    end
end)
