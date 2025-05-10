local Check = loadstring(game:HttpGet(""))()

for PlaceID, Execute in pairs(Check) do
    if PlaceID == game.PlaceId then
        loadstring(game:HttpGet(Execute))()
    end
end
