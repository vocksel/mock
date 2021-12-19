# Mock

[![CI](https://github.com/vocksel/mock/actions/workflows/ci.yml/badge.svg)](https://github.com/vocksel/mock/actions/workflows/ci.yml)

Package for creating [Jest](https://jestjs.io/)-like mocks for use with unit testing.

## Usage

```lua
-- example/init.lua
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
```

```lua
-- example/init.spec.lua
return function()
	local Mock = require(game.ReplicatedStorage.DevPackages.Mock)
	local example = require(script.Parent.example)

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
```

## Installation

### Wally

If you are using [Wally](https://github.com/UpliftGames/wally), add the following to your `wally.toml` and run `wally install` to get a copy of the package.

```
[dev-dependencies]
Mock = "vocksel/mock@v0.1.0
```

### Roblox Studio

* Download a copy of the rbxm from the [releases page](https://github.com/vocksel/mock/releases/latest) under the Assets section. 
* Drag and drop the file into Roblox Studio to add it to your experience.

## API

**`Mock.new(): Mock`**

Returns a new Mock instance.

Usage:

```lua
local Mock = require(game.ReplicatedStorage.DevPackages.Mock)

local mock = Mock.new()
```

When a mock is indexed, if the member does not exist (i.e. it is not listed in this API), a new Mock instance will be created. This allows you to build complex structures for your mocks:

```lua
local mockPlayers = Mock.new()

-- GetPlayers implicitly becomes a Mock 
mockPlayers.GetPlayers:mockImplementation(function()
    return { "Player1", "Player2" }
end)

print(mockPlayers:GetPlayers()) -- { "Player1", "Player2" }
print(#mockPlayers.GetPlayers.mock.calls) -- 1
```

**`Mock.is(other: any): boolean`**

Returns true if `other` is a Mock instance. False otherwise.

Usage:

```lua
local Mock = require(game.ReplicatedStorage.DevPackages.Mock)

local mock = Mock.new()

print(Mock.is(mock)) -- true
print(Mock.is("mock")) -- false
```

**`Mock.mock: table`**

Each Mock instance comes with a `mock` object with the following fields:
- `name: string`
    - The name of the Mock. By default, this is set to `"Mock"`. When indexing a mock, the implicitly created mocks are named after the key that was indexed.
        ```lua
        local mock = Mock.new()
        print(mock.foo.bar.mock.name) -- "bar"    
        ```
- `calls: table`
    - An array containing arrays of the arguments passed each time the mock is called.
    - It is helpful to get the length of this array to know how many times the mock was called.

**`Mock:mockImplementation(callback: (...any) -> any): nil`**

Sets the callback that gets run when a mock is called.

Usage:

```lua
local mock = Mock.new()

mock.timesTwo:mockImplementation(function(x: number)
    return x * 2
end)

print(mock.timesTwo(10)) -- 20
```

**`Mock:reset(): nil`**

Resets the mock between test cases.

Usage:

```lua
local mockFunction = Mock.new()

mockFunction()
print(#mockFunction.mock.calls) -- 1

mockFunction:reset()
print(#mockFunction.mock.calls) -- 0
```

If you define your mocks in the global scope of your tests, you should call `reset` in the `afterEach` hook. Note that this method also clears the implementation, so to retain it between tests you should set the implementation in `beforeEach`.

```lua
local mock = Mock.new()

beforeEach(function()
    mock:mockImplementation(function()
        return "implementation"
    end)
end)

afterEach(function()
    mock:reset()
end)
```

## Contributing

See the [contributing guide](CONTRIBUTING.md).

## License

[MIT License](LICENSE)