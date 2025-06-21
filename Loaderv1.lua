local Check = loadstring(game:HttpGet("https://raw.githubusercontent.com/LumeCraftors01/unknown-hub/refs/heads/main/Check.lua"))()

for PlaceID, Execute in pairs(Check) do
    if PlaceID == game.PlaceId then
        loadstring(game:HttpGet(Execute))()
    end
end
