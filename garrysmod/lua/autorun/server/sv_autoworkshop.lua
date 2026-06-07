local collection_id = "3740596531"

http.Post("https://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v1/", 
    {
        ["collectioncount"] = "1",
        ["publishedfileids[0]"] = collection_id
    },
    function(body)
        local data = util.JSONToTable(body)
        if not data or not data.response or not data.response.collectiondetails then return end
        
        local collection = data.response.collectiondetails[1]
        if collection and collection.children then
            print("\n[Marseille RP] --- LECTURE DE LA COLLECTION WORKSHOP ---")
            local count = 0
            for _, item in ipairs(collection.children) do
                if item.publishedfileid then
                    resource.AddWorkshop(item.publishedfileid)
                    print("-> Addon prepare pour les joueurs : " .. item.publishedfileid)
                    count = count + 1
                end
            end
            print("[Marseille RP] " .. count .. " addons trouves ! Les joueurs les telechargeront automatiquement en rejoignant.\n")
        end
    end,
    function(err)
        print("[Marseille RP] Erreur lors de la lecture de la collection : " .. tostring(err))
    end
)
