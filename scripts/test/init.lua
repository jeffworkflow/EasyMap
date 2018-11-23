
local test = {}

function test.init()
	
    print("加载testing系统")

	require 'test.memory_test'
	local player = require 'ac.player'
	local console = require 'jass.console'
	
	if not base.release then
		require 'test.helper'
	end
	
	-- if player.countAlive() == 1 then
	-- end
	
	console.enable = true
	helper = require 'test.helper'

	require 'test.global'
	require 'test.pairs'
	
	test.helper = helper

end	



return test;