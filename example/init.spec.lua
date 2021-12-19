return function()
	local Mock = require(game.ReplicatedStorage.DevPackages.Mock)
	local example = require(script.Parent)

	it("should get all the characters in the experience", function()
		local mockPlayers = Mock.new()

		-- Create a mock to represent a Player
		local mockPlayer = Mock.new()
		mockPlayer.Character = Instance.new("Model")

		-- Define the implementation of Players:GetPlayers()
		mockPlayers.GetPlayers:mockImplementation(function()
			return {
				mockPlayer,
			}
		end)

		-- Stub out the actual Players service with a mock
		example.Players = mockPlayers

		-- Our mocks are setup, so now we can test the getCharacters() function
		local characters = example:getCharacters()

		expect(#characters).to.equal(1)
		expect(characters[1]).to.equal(mockPlayer.Character)
	end)
end
