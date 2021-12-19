local Players = game:GetService("Players")

local example = {}

-- Exposing the Players service allows it to be mocked in tests
example.Players = Players

function example:getCharacters()
	local characters = {}
	for _, player in ipairs(example.Players:GetPlayers()) do
		if player.Character then
			table.insert(characters, player.Character)
		end
	end
	return characters
end

return example
