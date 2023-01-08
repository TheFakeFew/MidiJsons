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

local instruments = {
	{"rbxassetid://31173820", "standard kit", settings = {["Gain"] = 0.1}},
	{"rbxassetid://5924276201", "acoustic grand piano", settings = {["Gain"] = 0, ["Offset"] = -7}},
	{"rbxassetid://5924276201", "bright acoustic piano", settings = {["Gain"] = 0, ["Offset"] = -7}},
	{"rbxassetid://5924276201", "electric grand piano", settings = {["Gain"] = 0, ["Offset"] = -7}},
	{"rbxassetid://5924276201", "honky-tonk piano", settings = {["Gain"] = 0, ["Offset"] = -7}},
	{"rbxassetid://5924276201", "electric piano 1", settings = {["Gain"] = 0, ["Offset"] = -7}},
	{"rbxassetid://5924276201", "electric piano 2", settings = {["Gain"] = 0, ["Offset"] = -7}},
	{"rbxassetid://109618842", "harpsichord", settings = {["Offset"] = -12}},
	{"rbxasset://Sounds/electronicpingshort.wav", "clavinet"},
	{"rbxasset://Sounds/electronicpingshort.wav", "celesta"},
	{"rbxasset://Sounds/electronicpingshort.wav", "glockenspiel"},
	{"rbxasset://Sounds/electronicpingshort.wav", "music box"},
	{"rbxassetid://584691395", "vibraphone", settings = {["Gain"] = 0.4}},
	{"rbxasset://Sounds/electronicpingshort.wav", "marimba"},
	{"rbxassetid://19344667", "xylophone"},
	{"rbxassetid://109618842", "tubular bells"},
	{"rbxassetid://9040512197", "dulcimer", settings = {["Offset"] = 3}},
	{"rbxassetid://99666917", "drawbar organ"},
	{"rbxassetid://99666917", "percussive organ"},
	{"rbxassetid://99666917", "rock organ"},
	{"rbxassetid://99666917", "church organ"},
	{"rbxassetid://99666917", "reed organ"},
	{"rbxasset://Sounds/electronicpingshort.wav", "accordion"},
	{"rbxassetid://31173820", "room kit"},
	{"rbxasset://Sounds/bass.wav", "harmonica"},
	{"rbxassetid://12857654", "tango accordion"},
	{"rbxassetid://4007485270", "acoustic guitar (nylon)", settings = {["Gain"] = 0.3, ["Offset"] = 3}},
	{"rbxassetid://4007485270", "acoustic guitar (steel)", settings = {["Gain"] = 0.3, ["Offset"] = 3}},
	{"rbxassetid://4007485270", "electric guitar (jazz)", settings = {["Gain"] = 0.3, ["Offset"] = 3}},
	{"rbxassetid://4007485270", "electric guitar (clean)", settings = {["Gain"] = 0.3, ["Offset"] = 3}},
	{"rbxassetid://4007485270", "electric guitar (muted)", settings = {["Gain"] = 0.3, ["Offset"] = 3}},
	{"rbxassetid://4007485270", "overdriven guitar", settings = {["Gain"] = 0.3, ["Offset"] = 3}},
	{"rbxassetid://4007485270", "distortion guitar", settings = {["Gain"] = 0.3, ["Offset"] = 3}},
	{"rbxassetid://4007485270", "guitar harmonics", settings = {["Gain"] = 0.3, ["Offset"] = 3}},
	{"rbxasset://Sounds/bass.wav", "acoustic bass"},
	{"rbxasset://Sounds/bass.wav", "electric bass (finger)"},
	{"rbxasset://Sounds/bass.wav", "electric bass (pick)"},
	{"rbxasset://Sounds/bass.wav", "fretless bass"},
	{"rbxassetid://15666462", "slap bass 1"},
	{"rbxassetid://15666462", "slap bass 2"},
	{"rbxassetid://109618940", "synth bass 1"},
	{"rbxassetid://109618940", "synth bass 2"},
	{"rbxassetid://109618940", "synthbrass 1"},
	{"rbxassetid://13418521", "violin", settings = {["Offset"] = 4}},
	{"rbxassetid://12857654", "viola"},
	{"rbxassetid://12857654", "cello"},
	{"rbxasset://Sounds/bass.wav", "contrabass"},
	{"rbxassetid://109618754", "tremolo strings"},
	{"rbxasset://Sounds/bass.wav", "pizzicato strings"},
	{"rbxasset://Sounds/bass.wav", "orchestral harp"},
	{"rbxasset://Sounds/bass.wav", "timpani"},
	{"rbxassetid://75338648", "string ensemble 1"},
	{"rbxassetid://75338648", "string ensemble 2"},
	{"rbxassetid://11998777", "synthstrings 1"},
	{"rbxassetid://11998777", "synthstrings 2"},
	{"rbxasset://Sounds/bass.wav", "choir aahs"},
	{"rbxasset://Sounds/bass.wav", "voice oohs"},
	{"rbxasset://Sounds/bass.wav", "synth voice"},
	{"rbxasset://Sounds/bass.wav", "orchestral hit"},
	{"rbxasset://Sounds/bass.wav", "trumpet"},
	{"rbxasset://Sounds/bass.wav", "trombone"},
	{"rbxassetid://1846986991", "tuba"},
	{"rbxasset://Sounds/bass.wav", "muted trumpet"},
	{"rbxasset://Sounds/bass.wav", "french horn"},
	{"rbxasset://Sounds/bass.wav", "brass section"},
	{"rbxassetid://13418521", "synth brass 1"},
	{"rbxassetid://13418521", "synth brass 2"},
	{"rbxassetid://9040512197", "soprano sax", settings = {["Offset"] = 3, ["Gain"] = -0.2, ["Loop"] = true}},
	{"rbxassetid://9040512197", "alto sax", settings = {["Offset"] = 2, ["Gain"] = -0.2, ["Loop"] = true}},
	{"rbxassetid://9040512197", "tenor sax", settings = {["Offset"] = 3, ["Gain"] = -0.2, ["Loop"] = true}},
	{"rbxassetid://9040512197", "baritone sax", settings = {["Offset"] = -1, ["Gain"] = -0.2, ["Loop"] = true}},
	{"rbxassetid://1846986991", "oboe"},
	{"rbxassetid://13417380", "english horn"},
	{"rbxassetid://13424334", "bassoon", settings = {["Offset"] = -11}},
	{"rbxassetid://75338648", "clarinet"},
	{"rbxassetid://75338648", "piccolo"},
	{"rbxassetid://75338648", "flute", settings = {["Offset"] = -5}},
	{"rbxassetid://75338648", "recorder", settings = {["Offset"] = -13}},
	{"rbxasset://Sounds/bass.wav", "pan flute"},
	{"rbxassetid://75338648", "blown bottle"},
	{"rbxasset://Sounds/bass.wav", "shakuhachi"},
	{"rbxasset://Sounds/bass.wav", "whistle"},
	{"rbxasset://Sounds/bass.wav", "ocarina"},
	{"rbxassetid://9040512330", "lead 1 (square)", settings = {["Gain"] = -0.2, ["Loop"] = true, ["Offset"] = 3}},
	{"rbxassetid://9040512075", "lead 2 (sawtooth)", settings = {["Gain"] = -0.2, ["Loop"] = true, ["Offset"] = 3}},
	{"rbxassetid://9040512197", "lead 3 (calliope)", settings = {["Gain"] = -0.2, ["Loop"] = true, ["Offset"] = 3}},
	{"rbxasset://Sounds/bass.wav", "lead 4 (chiff)"},
	{"rbxasset://Sounds/bass.wav", "lead 5 (charang)"},
	{"rbxasset://Sounds/bass.wav", "lead 6 (voice)"},
	{"rbxasset://Sounds/bass.wav", "lead 7 (fifths)"},
	{"rbxassetid://9085536418", "lead 8 (bass + lead)", settings = {["Gain"] = -0.2, ["Loop"] = true, ["Offset"] = 3}},
	{"rbxasset://Sounds/bass.wav", "pad 1 (new age)"},
	{"rbxasset://Sounds/bass.wav", "pad 2 (warm)"},
	{"rbxasset://Sounds/bass.wav", "pad 3 (polysynth)"},
	{"rbxasset://Sounds/bass.wav", "pad 4 (choir)"},
	{"rbxasset://Sounds/bass.wav", "pad 5 (bowed)"},
	{"rbxasset://Sounds/bass.wav", "pad 6 (metallic)"},
	{"rbxasset://Sounds/bass.wav", "pad 7 (halo)"},
	{"rbxasset://Sounds/bass.wav", "pad 8 (sweep)"},
	{"rbxasset://Sounds/bass.wav", "fx 1 (rain)"},
	{"rbxasset://Sounds/bass.wav", "fx 2 (soundtrack)"},
	{"rbxasset://Sounds/bass.wav", "fx 3 (crystal)"},
	{"rbxassetid://12857654", "fx 4 (atmosphere)"},
	{"rbxasset://Sounds/bass.wav", "fx 5 (brightness)"},
	{"rbxasset://Sounds/bass.wav", "fx 6 (goblins)"},
	{"rbxasset://Sounds/bass.wav", "fx 7 (echoes)"},
	{"rbxassetid://12857654", "fx 8 (sci-fi)"},
	{"rbxassetid://12857654", "sitar"},
	{"rbxassetid://12857654", "banjo"},
	{"rbxasset://Sounds/electronicpingshort.wav", "shamisen"},
	{"rbxassetid://12857654", "koto"},
	{"rbxassetid://13414758", "kalimba"},
	{"rbxasset://Sounds/electronicpingshort.wav", "bag pipe"},
	{"rbxassetid://12857654", "fiddle"},
	{"rbxassetid://19344667", "shanai"},
	{"rbxassetid://13114759", "tinkle bell"},
	{"rbxassetid://13114759", "agogo"},
	{"rbxassetid://7149255551", "steel drums"},
	{"rbxassetid://31173820", "woodblock"},
	{"rbxassetid://31173820", "taiko drum"},
	{"rbxassetid://31173844", "melodic tom"},
	{"rbxassetid://7149255551", "synth drum"},
	{"rbxasset://Sounds/electronicpingshort.wav", "reverse cymbal"},
	{"rbxassetid://4007485270", "guitar fret noise"},
	{"rbxasset://Sounds/bass.wav", "breath noise"},
	{"rbxasset://Sounds/bass.wav", "seashore"},
	{"rbxasset://Sounds/bass.wav", "bird tweet"},
	{"rbxasset://Sounds/bass.wav", "telephone ring"},
	{"rbxassetid://106708146", "helicopter"},
	{"rbxassetid://10209257", "applause"},
	{"rbxassetid://5869422451", "oof"},
	{"rbxassetid://3546992780", "hood classic"},
	{"rbxassetid://1835905087", "alien"}
}
local families = {}

for i,v in next, instruments do
	families[v[2]] = {v[1],settings = v.settings or {}}
end

local chr = plr.Character
local rootpart = chr:WaitForChild("HumanoidRootPart")
UI.Parent = chr
UI.Adornee = rootpart
UI.StudsOffset = Vector3.new(0,3.5,0)
UI.AlwaysOnTop = false
local textlb = UI.TextBox
local songs = {}
local volmult = 1
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
		local tracks = data.tracks
		local notenum = 0
		local numofnotes = 0
		for i,v in next, tracks do
			numofnotes = numofnotes + #v.notes
		end
		textlb.Text = notenum.."/"..numofnotes
		for i,v in next, tracks do
			local id = "rbxassetid://0"
			print(v.instrument.name)
			if(families[v.instrument.name])then
				id = families[v.instrument.name]
			else
				id = families["acoustic grand piano"]
			end
			for i,v in next, v.notes do
				local thread
				thread = task.delay(v.time,function()
					notenum = notenum + 1
					textlb.Text = notenum.."/"..numofnotes.."\n"..v.time.."\n"..2^((v.midi-69)/12)
					local settings = id.settings
					local snd = Instance.new("Sound",rootpart)
					snd.Volume = v.velocity*volmult
					if(settings and settings["Gain"])then
						snd.Volume += settings["Gain"]
					end
					snd.SoundId = id[1]
					if(settings and settings["Loop"])then
						snd.Looped = settings["Loop"]
					end
					if(settings and settings["Offset"])then
						v.midi += settings["Offset"]
					end
					snd.Pitch = 2^((v.midi-69)/12)
					snd.Name = v.name
					snd:Play()
					task.delay(v.duration,function()
						local tw = game:GetService("TweenService"):Create(snd,TweenInfo.new(.1),{
							Volume = 0
						})
						tw:Play()
						tw.Completed:Wait()
						snd:Destroy()
					end)
				end)
				table.insert(songs,thread)
			end
		end
	end)()
end

game:GetService('RunService').Heartbeat:Connect(function()
	chr = plr.Character
	rootpart = chr:WaitForChild("HumanoidRootPart")
	pcall(function()
		UI.Parent = chr
		UI.Adornee = rootpart
	end)
end)

playsong("Roblox_Theme")
plr.Chatted:Connect(function(message)
	if(string.lower(message:sub(1,5)) == "play!")then
		local name = string.split(message,"!")[2]
		playsong(name)
	elseif(string.lower(message:sub(1,4)) == "vol!")then
		volmult = tonumber(string.split(message,"!")[2]) or 1
	end
end)