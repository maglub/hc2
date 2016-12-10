--[[
%% properties
-- 20 value
-- 25 value
-- 35 value
-- 47 value
%% globals
--]]

--#========================================
--# Description:
--# 
--# The triggering devices are 3 motion sensors and a door sensor that is connected to the office door lock.
--# 
--# The triggering devices are configured above, in the "%% properties" section.
--# The lights are configured below in the "lights" array.
--#
--# * If any motion sensor senses a motion, we should re-set the timer (global variable "officeLightsTimer") to the lightsOnTime (default 1200 seconds)
--# * We ignore any motion sensor that sends a deviceValue of 0, since we turn off the light when the timer reach 0
--# * If the door is locked, the motion sensors should be ignored.
--# * When the door locks all lights should be shut off, and any
--#   instance of this scene should be terminated.
--# * This scene is actually a long running scene, ca 1200 seconds.
--# * Any time the scene is re-entered, it checks if there is another scene running. If yes, it just re-sets the timer (global variable) and exits.
--# * In the long running loop, we are constantly polling the global variable to catch if another invocation of the scene has re-set the timer.
--# * At the end of the scene, the lights are turned off.
--#
--#========================================


--#========================================
-- Variables
--#========================================

local lights = {};
lights[1] = {["deviceID"] = 9};
lights[2] = {["deviceID"] = 10};
lights[3] = {["deviceID"] = 52};

local sceneId = 27;

local lightsOnTime=1200;
local lightsOnVariable="officeLightsTimer";

local motionSensorId=20;
local lockSensorId=25;

--#========================================
-- Functions
--#========================================

function lightsOn(lights)
  for slask, curLight in pairs(lights) do
	fibaro:debug("Turning on Light ID: " .. curLight['deviceID']);
    fibaro:call(curLight['deviceID'], "turnOn");
  end
end

function lightsOff(lights)
  for slask, curLight in pairs(lights) do
	fibaro:debug("Turning off Light ID: " .. curLight['deviceID']);
    fibaro:call(curLight['deviceID'], "turnOff");
  end
end

function remainder(a, b)
  local retVal = a - b*(math.floor(a/b));
  return retVal
end

--#========================================
-- Main
--#========================================

local trigger = fibaro:getSourceTrigger()
fibaro:debug("Trigger['type']: " .. trigger['type']);

if (trigger['type'] == 'property') then
  	local deviceID = trigger['deviceID'];
	local deviceValue = fibaro:getValue(deviceID, "value");
    local deviceName = fibaro:getName(deviceID);
  	fibaro:debug("* device: " .. deviceName .. " (#" .. deviceID .. ") has value: " .. deviceValue);

  if ( deviceValue == "0" and deviceName == "office-lock" ) then
    fibaro:debug("  - Someone just locked the door!");
    lightsOff(lights);
    fibaro:killScenes(sceneId);    
  end

  if ( deviceValue == "0" ) then
    fibaro:debug("  - Trying to exit!");
    -- if the motion sensor is shutting down, don't do anything
    return;
  end
end
  


fibaro:debug("Made it past the property check");

local numScenes=fibaro:countScenes(sceneId);

-- Check if scene is already running
if (numScenes > 1) then
  fibaro:debug("* Found more than one scene running simultaneously: " .. numScenes);
  fibaro:debug("  - Resetting timer to: " .. lightsOnTime);
  fibaro:setGlobal(lightsOnVariable, lightsOnTime);
  -- exit the scene
  return;
else
  fibaro:debug("* Number of scenes running simultaneously: " .. numScenes);
end


local res = lightsOn(lights);
fibaro:debug("  - Setting timer to: " .. lightsOnTime);
fibaro:setGlobal(lightsOnVariable, lightsOnTime);

while(fibaro:getGlobalValue(lightsOnVariable) ~= "0") do
  timerValue = tonumber(fibaro:getGlobalValue(lightsOnVariable));

  if (remainder(timerValue,10) == 0) then
    fibaro:debug("Loop - timer = " .. timerValue);
  end

  fibaro:setGlobal(lightsOnVariable, timerValue -1);
  
  fibaro:sleep(1000);
end

local res = lightsOff(lights);
  
