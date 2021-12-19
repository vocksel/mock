local None = newproxy()

local Mock = {}

function Mock.new(name: string?)
	local self = {}

	self._returnValue = None
	self._implementation = None
	self._children = {}

	self.mock = {
		name = name or "Mock",
		calls = {},
		results = {},
	}

	return setmetatable(self, Mock)
end

function Mock:__index(key: string)
	local member = rawget(self, key) or rawget(Mock, key)
	if member then
		return member
	end

	local returnValue = rawget(self, "_returnValue")
	if returnValue ~= None then
		return returnValue
	end

	local mock = self._children[key]
	if not mock then
		mock = Mock.new(key)
		self._children[key] = mock
	end
	return mock
end

function Mock:__call(...)
	local args = table.pack(...)
	table.insert(self.mock.calls, args)

	local implementation = rawget(self, "_implementation")
	if implementation ~= None then
		return implementation(...)
	end
end

function Mock:__tostring()
	return self.mock.name
end

function Mock.is(other: any): boolean
	return typeof(other) == "table" and other.mock ~= nil
end

function Mock:mockImplementation(implementation: () -> nil): nil
	if implementation == nil then
		implementation = None
	end
	self._implementation = implementation
end

function Mock:reset()
	self.mock.calls = {}
	self._implementation = None
end

return Mock
