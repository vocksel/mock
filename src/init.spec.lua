return function()
	local Mock = require(script.Parent)

	it("has a 'mock' property", function()
		local mock = Mock.new()
		expect(mock.mock).to.be.ok()
	end)

	it("returns a new Mock instance when indexing", function()
		local mock = Mock.new()
		expect(Mock.is(mock.foo)).to.equal(true)
	end)

	it("allows arbitrary values to be assigned to the mock", function()
		local mock = Mock.new()

		mock.foo = true
		expect(mock.foo).to.equal(true)

		mock.bar.baz = "string"
		expect(mock.bar.baz).to.equal("string")
	end)

	it("returns the same mock when indexing a child", function()
		local mock = Mock.new()
		expect(mock.foo.bar).to.equal(mock.foo.bar)
	end)

	describe("name", function()
		it("sets the mock's name to 'Mock' by default", function()
			local mock = Mock.new()
			expect(mock.mock.name).to.equal("Mock")
		end)

		it("sets the mock's name to the name of the key", function()
			local mock = Mock.new()
			expect(mock.foo.mock.name).to.equal("foo")
		end)
	end)

	describe("__call", function()
		-- To return a different value when called, mockImplementation() is used.
		it("returns nil by default", function()
			local mock = Mock.new()
			expect(mock()).to.equal(nil)
		end)

		it("adds an empty table to the 'calls' array when passed no arguments", function()
			local mock = Mock.new()

			mock()

			local firstCall = mock.mock.calls[1]

			expect(firstCall).to.be.a("table")
			expect(#firstCall).to.equal(0)
		end)

		it("adds the passed argument to the 'calls' array when called", function()
			local mock = Mock.new()

			mock("foo", "bar")

			local firstCall = mock.mock.calls[1]

			expect(firstCall[1]).to.equal("foo")
			expect(firstCall[2]).to.equal("bar")
		end)

		it("handles consecutive calls", function()
			local mock = Mock.new()

			-- The iterations are arbitary. We just need to loop enough that we
			-- have certainty that this case works all the time.
			for i = 1, 5 do
				mock(i)

				local call = mock.mock.calls[i]
				expect(call[1]).to.equal(i)

				local nextCall = mock.mock.calls[i + 1]
				expect(nextCall).to.never.be.ok()
			end

			expect(#mock.mock.calls).to.equal(5)
		end)
	end)

	describe("__tostring", function()
		it("returns 'Mock' if no name was set", function()
			expect(tostring(Mock.new())).to.equal("Mock")
		end)

		it("returns the name of the key if it was indexed on another mock", function()
			local mock = Mock.new()
			expect(tostring(mock.foo.bar)).to.equal("bar")
		end)
	end)

	describe("Mock.is()", function()
		it("returns true for Mock instances", function()
			local mock = Mock.new()
			expect(Mock.is(mock)).to.equal(true)
		end)

		it("returns false for primitives", function()
			local primitives = {
				true,
				"string",
				1234,
				{ foo = true },
			}

			for _, primitive in ipairs(primitives) do
				expect(Mock.is(primitive)).to.equal(false)
			end
		end)
	end)

	describe("Mock:mockImplementation()", function()
		it("mocks the implementation", function()
			local mock = Mock.new()

			mock.foo.bar:mockImplementation(function(x: number)
				return x * 2
			end)

			expect(mock.foo.bar(10)).to.equal(20)
		end)
	end)

	describe("Mock:reset()", function()
		it("resets the `calls` array", function()
			local mock = Mock.new()

			mock()
			expect(#mock.mock.calls).to.equal(1)

			mock:reset()
			expect(#mock.mock.calls).to.equal(0)
		end)

		it("resets the mocked implementation", function()
			local mock = Mock.new()
			mock:mockImplementation(function()
				return true
			end)

			expect(mock()).to.equal(true)

			mock:reset()

			expect(mock()).to.never.equal(true)
		end)
	end)
end
