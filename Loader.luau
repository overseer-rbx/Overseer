local Repo = "https://raw.githubusercontent.com/cryogen-rbx/Cryogen/refs/heads/main/games/"

local Ok, Content = pcall(game.HttpGet, game, Repo..game.PlaceId..".luau", true)

if not Ok or Content == "404: Not Found" then
        loadstring(game:HttpGet(Repo.."Universal.luau", true))()
else
        loadstring(Content, "Cryogen")()
end