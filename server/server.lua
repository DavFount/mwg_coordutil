RegisterServerEvent("mwg_coordutil:export", function(coords)
    SaveResourceFile(GetCurrentResourceName(), "./coords.json", json.encode(coords))
end)
