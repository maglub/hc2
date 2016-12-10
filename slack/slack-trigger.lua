--[[
%% properties
36 value
71 value
74 value
84 value
-- 80 value
-- 82 value
%% globals
--]]

--==============================================
--
-- Author: Magnus Luebeck
--
-- slack chat integration
-- Script name: slack-trigger
--
-- This scene will trigger on events from (mainly) the door sensors that you define in the %% properties
-- section. This scene will call another scene (most likely the scene "slack-send") after setting the
-- global variable "slackMessage" with a string (message) to send.
--
-- Dependencies:
--
-- * a global variable named "slackMessage" has to be added in Panels->Variables Panel->Variables
-- 
-- NOTE:
-- * The devices that trigger a slack message are listed above under "%% properties" by device ID
-- * The first device must not be commented out, as that will break the trigger
-- * This scene will overwrite the value of the variable "slackMessage", which triggers the scene "slack-send"
--
--==============================================

local debugID = 36;

fibaro:debug("#==========================");
local trigger = fibaro:getSourceTrigger()
fibaro:debug("Trigger['type']: " .. trigger['type']);

local deviceID = 0;
local deviceName = "";
local triggerValue = 0;

-- currently we only look at properties
if (trigger['type'] == 'property') then
    deviceID = trigger['deviceID'];
    deviceName = fibaro:getName(deviceID);
    triggerValue = fibaro:getValue(deviceID, "value") --Get Door sensor value that activated this scene
else
    -- the scene was started manually
    deviceID = debugID;
    deviceName = "Debug: " .. os.time();
    triggerValue = 0;
end

local slackMessage = "Sensor " .. deviceName .. " (#" .. deviceID .. ") ";
slackMessage = slackMessage .. (tonumber(triggerValue) > 0 and "open" or "closed");

-- setting the global variable "slackMessage", which will
-- be consumed in the slack scene
fibaro:debug("Setting message to: " .. slackMessage);
fibaro:setGlobal("slackMessage", slackMessage);  

