--[[
License:
    Copyright (C) 2021  QuantixDev

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

Description:
	The Qubit Noise Library, is based off noise libraries that may be used in professional game development.
	This noise library contains many features to create a smooth or noisy terrain generation or however you use it.
	The functions are all documented for use and this module is open source as most of the code can be found anyway.
	It was intented to be used in conjuction with my Terrain Generator, but I decided to open source due to the usefullness of
	the module.

General Terminology:
	Some terminology in this script may confuse you, I have compiled a list of the terms and their definitions below.
	this serves to describe them and be a "dictionary" for those words:
		Scale - How big the Noise will be (think of it as a 2D Texture)
		Octaves - Combines multiple NoiseMaps to create a more natural looking Noise
		Persistence - The multiplier that determines how quickly amplitudes decreases each octave.
		Lacunarity - The multiplier that determines how quickly the frequency increases each octave.
		Offset - Allows you to "scroll" through the noise, think of a webpage when you scroll through.
		Seed - A value that lets you recreate the same noise, leaving it to tick() will create a semi-random noise value.
]]

local RunService = game:GetService("RunService")

local MAX_NOISE_HEIGHT = -100
local MIN_NOISE_HEIGHT = -MAX_NOISE_HEIGHT

local noiseDeliver = {}
local noise = {}

--[[
Normalises a value with min and max between 0-1
Returns <number> _normalisedValue
(<number> _value, <number> _min, <number> _max)
	- _value is the value you're normalising.
	- _min is the minimum number that value can be.
	- _max is the maximum number that value can be.
]]
local function normalise(_value, _min, _max)
	return (_value - _min) / (_max - _min);
end


--[[
@description Generates a 2DNoiseMap while simulataneously capable of being used
@usage generate2DPartialMap(noiseWidth, noiseHeight, seed, scale, octaves, persistence, lacunarity, offset)
@usage generate2DPartialMap(<dictionary> settings)
@returns <BindableEvent> noiseAdded [returns: <2D Partial NoiseMap>]
]]
noise.generate2DPartialMap = function(_width, _height, _seed, _scale, _octaves, _persistence, _lacunarity, _offset, _normalise)
	-- Allowing the entry of tables (im not proud of this)
	if type(_width) == "table" and _width.width then
		_height = _width.height
		_seed = _width.seed
		_scale = _width.scale
		_octaves = _width.octaves
		_persistence = _width.persistence
		_lacunarity = _width.lacunarity
		_offset = _width.offset
		_normalise = _width.normalise
		_width = _width.width
	end

	-- applying defaults
	_width = _width or 50
	_height = _height or 50
	_seed = _seed or 1
	_scale = _scale or 25
	_offset = _offset or Vector2.new(0, 0)
	_normalise = _normalise or false
	_octaves = _octaves or 1
	_lacunarity = _lacunarity or 1
	_persistence = _persistence or 0.5

	-- Type Checking
	assert(typeof(_width) == "number", "Width must be a number, given: " .. typeof(_width))
	assert(typeof(_height) == "number", "Height must be a number, given: " .. typeof(_height))
	assert(typeof(_seed) == "number", "Seed must be a number, given: " .. typeof(_seed))
	assert(typeof(_scale) == "number" and _scale > 0, "Scale must be a number more than 0, given: " .. _scale)
	assert(typeof(_octaves) == "number", "Octaves must be a number.")
	assert(typeof(_persistence) == "number" and _persistence >= 0 and _persistence <= 1, "Persistence must be a number between 0 and 1.")
	assert(typeof(_lacunarity) == "number" and _lacunarity >= 1, "Lacunarity must be a number more than or equal to 1.")
	assert(typeof(_offset) == "Vector2", "Offset must be a Vector2.")

	noiseDeliver[_seed] = {}

	local elementAdded, generationFinished = Instance.new("BindableEvent"), false
	coroutine.wrap(function()
		local octaveOffsets = {}
		local randomClass = Random.new(_seed)
		local widthHalf = _width / 2
		local heightHalf = _height / 2
		noiseDeliver[_seed]["MinNoise"] = MIN_NOISE_HEIGHT
		noiseDeliver[_seed]["MaxNoise"] = MAX_NOISE_HEIGHT

		-- octaves, more octaves make for a more natural noise (essentially offsets the noise more and more)
		for i=0, _octaves-1 do
			local xOffset = randomClass:NextInteger(-10000, 10000) + _offset.X
			local yOffset = randomClass:NextInteger(-10000, 10000) + _offset.Y

			table.insert(octaveOffsets, i, Vector2.new(xOffset, yOffset))
		end

		-- creating a noise map for the scale _width * _height
		for x=1, _width do
			noiseDeliver[_seed][x] = {}

			for y=1, _height do	
				local frequency, amplitude, noiseHeight = 1, 1, 0
				for ocI=0, _octaves-1 do
					local sampleX = (x - widthHalf) / _scale * frequency + octaveOffsets[ocI].x
					local sampleY = (y - heightHalf) / _scale * frequency + octaveOffsets[ocI].y

					-- using the built-in c noise function
					local noiseValue = math.noise(sampleX, sampleY) * 2 - 1
					noiseHeight = noiseHeight + (noiseValue * amplitude)

					-- applying the persistence and lacunarity values
					amplitude = amplitude * _persistence
					frequency = frequency * _lacunarity
				end

				-- getting the min and max
				noiseDeliver[_seed]["MinNoise"] = math.min(noiseHeight, noiseDeliver[_seed]["MinNoise"])
				noiseDeliver[_seed]["MaxNoise"] = math.max(noiseHeight, noiseDeliver[_seed]["MaxNoise"])
				noiseDeliver[_seed][x][y] = noiseHeight
			end
		end

		-- another loop here, to clamp the noise values		
		for x=1, _width do
			for y=1, _height do
				if not noiseDeliver[_seed][x][y] then 
					noiseDeliver[_seed][x][y] = 1 
				end

				if _normalise then
					noiseDeliver[_seed][x][y] = normalise(noiseDeliver[_seed][x][y], noiseDeliver[_seed]["MinNoise"], noiseDeliver[_seed]["MaxNoise"])	
				end
				elementAdded:Fire(x, y, noiseDeliver[_seed][x][y])
			end
		end

		generationFinished = true
	end)()

	return elementAdded.Event, generationFinished
end

--[[
@description Creates a 2D noiseMap which is a table full of 2D Noise Values (to save on calculations)
@usage generate2DNoiseMap(noiseWidth, noiseHeight, seed, scale, octaves, persistence, lacunarity, offset)
@usage generate2DNoiseMap(<dictionary> settings)
@returns <2D Dictionary> noiseMap[x][y]
]]
noise.generate2DNoiseMap = function(...)
	local args = {...}
	local seed = args[3] or args[1].seed or 1

	local onNoiseAdded, noiseGenerated = noise.generate2DPartialMap(...)
	while not noiseGenerated and not noiseDeliver[seed] do
		onNoiseAdded:Wait()
	end

	return noiseDeliver[seed]
end

--[[
@description Generates a radial gradient around _center of values in a table.
@usage generateRadialGradient(width, length, center, doNormalisation)
@returns <2D Dictionary> or noisemap["min"] / noisemap["max"]
]]
noise.generateRadialGradient = function(_width, _length, _doNormalisation)
	local gradients = {}
	gradients["min"] = MIN_NOISE_HEIGHT
	gradients["max"] = MAX_NOISE_HEIGHT

	local center = Vector3.new(_width / 2, 1, _length / 2)
	local shouldNormalise = false
	for _=0, 1 do
		for x = 1, _width do
			gradients[x] = gradients[x] or {}

			for z = 1, _length do
				if not shouldNormalise then
					local pos = Vector3.new(x, 1, z)
					local dist = (pos - center).magnitude * 0.005
					local clr = dist % 2
					clr = (clr > 1) and (2 - clr) or clr

					gradients[x][z] = math.clamp(math.abs((clr - 1)), 0, 1)
					gradients["min"] = math.min(gradients[x][z], gradients["min"])
					gradients["max"] = math.max(gradients[x][z], gradients["max"])
				else
					gradients[x][z] = normalise(gradients[x][z], gradients["min"], gradients["max"])
				end
			end

			RunService.Heartbeat:Wait()
		end

		if _doNormalisation and not shouldNormalise then
			shouldNormalise = true 
		else
			break
		end
	end

	return gradients
end

return noise