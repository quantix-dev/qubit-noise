# Qubit Noise Library
A noise library designed specifically for usage with Roblox (luau), easily create a noise map in seconds.

<br>

## Table of Contents
- [Table of Contents](#table-of-contents)
  * [About](#about)
  * [Installation](#installation)
  * [Documentation](#documentation)
    + [Partial2DNoiseMap](#partial2dnoisemap)
      - [Usage](#usage)
      - [Examples](#examples)
        * [Generate via Arguments](#generate-via-arguments)
        * [Generate via NoiseSettings](#generate-via-noisesettings)
    + [2D Noise Map (Preferred Method)](#2d-noise-map--preferred-method-)
      - [Usage](#usage-1)
      - [Examples](#examples-1)
        * [Generate via Arguments](#generate-via-arguments-1)
        * [Generate via NoiseSettings](#generate-via-noisesettings-1)

## About
This noise library serves to easily and quickly generate hundreds - if not thousands - of noise values almost immediately. Noise is an extremely useful tool for game developers (especially those making procedural terrain). This library allows you to run 1 function and get a noise value whilst still remaining performant and easy to use.

## Installation
You can find the latest release - or past version - of this module [here](https://github.com/quantix-dev/qubit-noise/releases). You may select from the regular *non-typed* version or the **luau-typed**\* version.

Once you have downloaded the .lua files, you can put it into your preferred development environment and simply require it just like a regular module.

\* Typed version still in development

## Documentation
Below you will find the functions included in the library, and how to use them.

<br>

### Partial2DNoiseMap
This generates a 2D Noise map asynchronously (does not yield the thread) and returns a RBXScriptSignal which is fired every time a new noise value is added. (This is also used internally by the preferred generate function.

#### Usage
`generate2DPartialMap(<float> width, <float> height, <float> [optional] seed, <float> scale, <int> [optional] octaves, <float> persistence, <float> lacunarity, <Vector2> [optional] offset, <boolean> normalize)`

`generate2DPartialMap(Dictionary NoiseSettings)`
Allowed values in the **NoiseSettings Dictoinary**:
```lua
{
    width = 1, 
    height = 1,
    seed = 1, -- *optional
    scale = 1,
    octaves = 1, -- *optional
    persistence = 0.5, 
    lacunarity = 1,
    offset = Vector2.new(0, 0), -- *optional
    normalise = false -- *optional
}
```

#### Examples

##### Generate via Arguments
```lua
-- Using the function to generate the noise event
-- * means optional
local NoiseGeneratedEvent = QubitNoise.generate2DPartialMap(xSize, ySize, seed*, scale*, octaves*, persistence, lacunarity, offset, normalizeValues*)

-- Using the noise event to detect when a noise value is generated
NoiseGeneratedEvent:Connect(function(x, y, noise)
    print(string.format("%d, %d = %f", x, y, noise))
end)
```

##### Generate via NoiseSettings
```lua
-- Using a NoiseSettings table allows you to skip optional arguments.
local NoiseSettings = {
    width = x,
    height = y,
    scale = 15, 
    persistence = 0.5,
    lacunarity = 1
}

-- Using the function to generate the noise event
local NoiseGeneratedEvent = QubitNoise.generate2DPartialMap(NoiseSettings)

-- Using the noise event to detect when a noise value is generated
NoiseGeneratedEvent:Connect(function(x, y, noise)
    print(string.format("%d, %d = %f", x, y, noise))
end)
```

<br>
<hr>

### 2D Noise Map (Preferred Method)
This generates a 2D Noise map synchronously (yields the thread until completed). This is the **Preferred Method** of generation, as it internally calls generatePartial. It functions identially similiar to the partial generator however it returns a full table of noise values compared to an event.

#### Usage
`generate2DNoiseMap(<float> width, <float> height, <float> [optional] seed, <float> scale, <int> [optional] octaves, <float> persistence, <float> lacunarity, <Vector2> [optional] offset, <boolean> normalize)`

`generate2DNoiseMap(Dictionary NoiseSettings)`
Allowed values in the **NoiseSettings Dictoinary**:
```lua
{
    width = 1, 
    height = 1,
    seed = 1, -- *optional
    scale = 1,
    octaves = 1, -- *optional
    persistence = 0.5, 
    lacunarity = 1,
    offset = Vector2.new(0, 0), -- *optional
    normalise = false -- *optional
}
```

#### Examples

##### Generate via Arguments
```lua
-- Using the function to generate the noise event
-- * means optional
local noise = QubitNoise.generate2DPartialMap(xSize, ySize, seed*, scale*, octaves*, persistence, lacunarity, offset, normalizeValues*)

-- Outputting every noise value from 0-50
for x=1, 51, 1 do
   for y=1, 51, 1 do 
       print(string.format("1, 1 = %f", noise[x][y]))
   end
end
```

##### Generate via NoiseSettings
```lua
-- Using a NoiseSettings table allows you to skip optional arguments.
local NoiseSettings = {
    width = 50,
    height = 50,
    scale = 15, 
    persistence = 0.5,
    lacunarity = 1
}

-- Using the function to generate the noise event
local noise= QubitNoise.generate2DNoiseMap(NoiseSettings)

-- Outputting every noise value from 0-50
for x=1, 51, 1 do
   for y=1, 51, 1 do 
       print(string.format("1, 1 = %f", noise[x][y]))
   end
end
```

