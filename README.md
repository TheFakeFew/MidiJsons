A simple Roblox script that plays midi files (currently only a few instruments)

```lua
local raw = game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/TheFakeFew/MidiJsons/main/RobloxScript.lua",true)
if(not raw)then
    print('Failed to get raw')
end
print('Loading raw')
local load,err = loadstring(raw)
if(not load)then print("Failed to load: ",err) else load() end
```
