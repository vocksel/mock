local Mock = {}
Mock.__index = Mock

function Mock.new(name: string?)
	local self = {}

	local meta = {
		__index = function(_self, key: string)
			local returnValue = rawget(self, "_returnValue")

			print("returnValue", returnValue)

			local member = rawget(self, key) or rawget(Mock, key)

			if member then
				return member
			else
				return Mock.new(key)
			end
		end,

		__tostring = function(_self)
			return self.mock.name
		end,

		__call = function(_self, ...)
			local args = table.pack(...)
			table.insert(self.mock.calls, args)

			if self._implementation then
				return self._implementation(...)
			end
		end,
	}

	self.mock = {
		name = name or "Mock",
		calls = {},
		results = {},
	}

	self._returnValue = nil
	self._implementation = nil

	return setmetatable(self, meta)
end

function Mock.is(other: any): boolean
	return typeof(other) == "table" and other.mock ~= nil
end

function Mock:mockReturnValue(returnValue: any): nil
	print("_returnValue", returnValue)
	rawset(self, "_returnValue", returnValue)
end

function Mock:mockImplementation(implementation: () -> nil): nil
	print("_implementation", implementation)
	rawset(self, "_implementation", implementation)
end

function Mock:reset()
	self.mock.calls = {}
end

return Mock
