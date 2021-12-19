
local mock = Mock.new()

mock.test.something.mockReturnValue(true)

print(mock.test.something)

mock.test.func.mockImplementation(function(x)
    return x + 10
end)

print(mock.test.func(10))

Mock class:

Methods:
- mockReturnValue()
- mockImplementation(impl: (callback: () -> nil) -> nil)

Properties:
mock = {
    calls = {},
    results = {},
}

Implementation details:
- Any access of undefined member will return a new Mock instance


return function()
    
end