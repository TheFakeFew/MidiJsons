A simple Roblox script that plays midi files (currently only 2 instruments)

```lua
local raw = game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/TheFakeFew/MidiJsons/main/RobloxScript.lua")
local load,err = loadstring(raw)
if(not load)then print("Failed to load: ",err) else load() end
```
