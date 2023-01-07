--Made by TheFakeFew/foxynason

local genv={}
Decode =  function(str,t,props,classes,values,ICList,Model,CurPar,LastIns,split,RemoveAndSplit,InstanceList)
	local tonum,table_remove,inst,parnt,comma,table_foreach = tonumber,table.remove,Instance.new,"Parent",",",
	function(t,f)
		for a,b in pairs(t) do
			f(a,b)
		end
	end
	local Types = {
		Color3 = Color3.new,
		Vector3 = Vector3.new,
		Vector2 = Vector2.new,
		UDim = UDim.new,
		UDim2 = UDim2.new,
		CFrame = CFrame.new,
		Rect = Rect.new,
		NumberRange = NumberRange.new,
		BrickColor = BrickColor.new,
		PhysicalProperties = PhysicalProperties.new,
		NumberSequence = function(...)
			local a = {...}
			local t = {}
			repeat
				t[#t+1] = NumberSequenceKeypoint.new(table_remove(a,1),table_remove(a,1),table_remove(a,1))
			until #a==0
			return NumberSequence.new(t)
		end,
		ColorSequence = function(...)
			local a = {...}
			local t = {}
			repeat
				t[#t+1] = ColorSequenceKeypoint.new(table_remove(a,1),Color3.new(table_remove(a,1),table_remove(a,1),table_remove(a,1)))
			until #a==0
			return ColorSequence.new(t)
		end,
		number = tonumber,
		boolean = function(a)
			return a=="1"
		end
	}
	split = function(str,sep)
		if not str then return end
		local fields = {}
		local ConcatNext = false
		str:gsub(("([^%s]+)"):format(sep),function(c)
			if ConcatNext == true then
				fields[#fields] = fields[#fields]..sep..c
				ConcatNext = false
			else
				fields[#fields+1] = c
			end
			if c:sub(#c)=="\\" then
				c = fields[#fields]
				fields[#fields] = c:sub(1,#c-1)
				ConcatNext = true
			end
		end)
		return fields
	end
	RemoveAndSplit = function(t)
		return split(table_remove(t,1),comma)
	end
	t = split(str,";")
	props = RemoveAndSplit(t)
	classes = RemoveAndSplit(t)
	values = split(table_remove(t,1),'|')
	ICList = RemoveAndSplit(t)
	InstanceList = {}
	Model = inst"Model"
	CurPar = Model
	table_foreach(t,function(ct,c)
		if c=="n" or c=="p" then
			CurPar = c=="n" and LastIns or CurPar[parnt]
		else
			ct = split(c,"|")
			local class = classes[tonum(table_remove(ct,1))]
			if class=="UnionOperation" then
				LastIns = {UsePartColor="1"}
			else
				LastIns = inst(class)
				if LastIns:IsA"Script" then
					s(LastIns)
				elseif LastIns:IsA("ModuleScript") then
					ms(LastIns)
				end
			end

			local function SetProperty(LastIns,p,str,s)
				s = Types[typeof(LastIns[p])]
				if p=="CustomPhysicalProperties" then
					s = PhysicalProperties.new
				end
				if s then
					LastIns[p] = s(unpack(split(str,comma)))
				else
					LastIns[p] = str
				end
			end

			local UnionData
			table_foreach(ct,function(s,p,a,str)
				a = p:find":"
				p,str = props[tonum(p:sub(1,a-1))],values[tonum(p:sub(a+1))]
				if p=="UnionData" then
					UnionData = split(str," ")
					return
				end
				if class=="UnionOperation" then
					LastIns[p] = str
					return
				end
				SetProperty(LastIns,p,str)
			end)

			if UnionData then
				local LI_Data = LastIns
				LastIns = DecodeUnion(UnionData)
				table_foreach(LI_Data,function(p,str)
					SetProperty(LastIns,p,str)
				end)
			end
			table.insert(InstanceList,LastIns)
			LastIns[parnt] = CurPar
		end
	end)
	table_remove(ICList,1)
	table_foreach(ICList,function(a,b)
		b = split(b,">")
		InstanceList[tonum(b[1])][props[tonum(b[2])]] = InstanceList[tonum(b[3])]
	end)

	return Model:GetChildren()
end
local Objects = Decode('Name,Size,Active,ClipsDescendants,AlwaysOnTop,ZIndexBehavior,BackgroundColor3,BackgroundTransparency,Font,TextColor3,TextScaled,TextSize,TextStrokeColor3,TextStrokeTransparency,TextWrapped;Part,Billbo'
	..'ardGui,TextBox;Part|5,0,2,0|1|1|1,0,1,0|1,1,1|3|20|0.2235,0.2235,0.2235|0;0;2|2:2|3:3|4:3|5:3|6:4;n;3|2:5|7:6|8:3|9:7|10:6|11:3|12:8|13:9|14:10|15:3;p;')
local UI = Objects[1]

function getData(songname)
	local json = game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/TheFakeFew/MidiJsons/main/"..songname..".json")
	if(not json)then
		return nil
	end
	return game:GetService("HttpService"):JSONDecode(json)
end

local plr = owner
if(not getfenv().owner)then
	plr = script.Parent:IsA("PlayerGui") and script.Parent.Parent or game:GetService('Players'):GetPlayerFromCharacter(script.Parent)
end
local families = {
	["piano"] = {
		["acoustic grand piano"] = "rbxassetid://5924276201",
		["standard"] = "rbxassetid://5924276201"
	},
	["drums"] = {
		["standard kit"] = "rbxassetid://31173820"
	}
}
local chr = plr.Character
local rootpart = chr:WaitForChild("HumanoidRootPart")
UI.Parent = chr
UI.Adornee = rootpart
UI.StudsOffset = Vector3.new(0,3.5,0)
UI.AlwaysOnTop = false
local textlb = UI.TextBox
local songs = {}
function playsong(songname)
	coroutine.wrap(function()
		for i,v in next, songs do
			task.cancel(v)
		end
		textlb.Text = "Loading.."
		print("loading "..songname)
		local data = getData(songname)
		if(not data)then
			textlb.Text = "Song doesnt exist."
			print("Song doesnt exist.")
		end
		print("loaded "..songname)
		local bpm = 60/data.header.tempos[1].bpm
		local tracks = data.tracks
		local notenum = 0
		local numofnotes = 0
		for i,v in next, tracks do
			numofnotes = numofnotes + #v.notes
		end
		textlb.Text = notenum.."/"..numofnotes
		for i,v in next, tracks do
			local id = "rbxassetid://0"
			print(v.instrument.family,v.instrument.name)
			if(families[v.instrument.family] and families[v.instrument.family][v.instrument.name])then
				id = families[v.instrument.family][v.instrument.name]
			else
				id = families.piano.standard
			end
			for i,v in next, v.notes do
				local thread
				thread = task.delay(v.time,function()
					notenum = notenum + 1
					textlb.Text = notenum.."/"..numofnotes.."\n"..v.time.."\n"..2^((v.midi-69)/12)
					local snd = Instance.new("Sound",rootpart)
					snd.Volume = v.velocity
					snd.SoundId = id
					snd.Looped = true
					snd.Pitch = 2^((v.midi-69)/12)
					snd.Name = v.name
					snd:Play()
					task.delay(v.duration,snd.Destroy,snd)
				end)
				table.insert(songs,thread)
			end
		end
	end)()
end
game:GetService('RunService').Heartbeat:Connect(function()
	chr = plr.Character
	rootpart = chr:WaitForChild("HumanoidRootPart")
	UI.Parent = chr
	UI.Adornee = rootpart
end)
playsong("Roblox_Theme")
plr.Chatted:Connect(function(message)
	if(message:sub(1,5) == "play!")then
		local name = string.split(message,"!")[2]
		playsong(name)
	elseif message:sub(1,9) == "getsongs!" then

	end
end)