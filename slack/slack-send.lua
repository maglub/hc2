--[[
%% properties

%% globals
slackMessage
--]]

--==============================================
-- Name: slack
-- Description: 
-- slack chat integration. this script will send a message
-- to a slack channel
--
-- Dependencies: 
--
-- * global variable "slackMessage" -> this scene is triggered when the global variable "slackMessage" is changed
--   NOTE: The global variable slackMessage has to exist before you "save" this scene. Otherwise the scene will not
--         be triggered by the global variable.
--   NOTE: If the slackMessage is changed per REST, you must also set "invokeScenes":true in your call
--         This curl is a good way to troubleshoot this scene.
--
--   curl -X PUT -d '{"value":"0","invokeScenes":true}' http://HC2_USER:HC2_PASSWORD@HC2_IP/api/globalVariables/slackMessage
-- 
-- * global variable slackKey => the secret slack key that you got
--                        when you set up the web hook at http://slack.com
-- * variable slackChannel => The channel you want the chat to go to
--
-- Create the global variable "slackMessage" as a normal variable in Panels->Variables Panel->Variables
-- Create the global variable "slackKey" as a Predefined variable in Panels->Variables Panel->Predefined variables 
-- Optionally create the global variable "slackUsername" as a Predefined variable in Panels->Variables Panel->Predefined variables 
-- Optionally Create the global variable "slackChannel" as a Predefined variable in Panels->Variables Panel->Predefined variables 

--==============================================

--================================================
-- Variables
--================================================

local slackMessage = fibaro:getGlobalValue('slackMessage');
if (slackMessage == nil or slackMessage == '') then
    -- This scene will not be triggered a second time if the global "slackMessage" is set to the same value twice
    -- we have to "reset" the slackMessage at the end of this script.
    -- The "" in slackMessage will in turn triggers this script, so we should just abort if it is empty.
    fibaro:abort();
end

-- local slackKey = "SECRET_APPLICATION_KEY";
local slackKey = fibaro:getGlobalValue('slackKey');
if (slackKey == nil or slackKey == '') then
    fibaro:debug("Error: no slackKey global variable defined - exiting");
    fibaro:abort();
end

local username = fibaro:getGlobalValue('slackUsername');
if ( username == nil ) then
  username = "HC2";
end

local slackChannel = fibaro:getGlobalValue('slackChannel');

if (slackChannel == nil) then
    slackChannel = "#hc2"
end

local SLACK = net.HTTPClient();
local url = "https://hooks.slack.com/services/" .. slackKey;

--================================================
-- Start
--================================================

fibaro:debug("#==========================");

local trigger = fibaro:getSourceTrigger()
fibaro:debug("Trigger['type']: " .. trigger['type']);
fibaro:debug("Set up the url: " .. url);

local message = "msg: " .. slackMessage;
res = SLACK:request(
  url,{ 
    options = {
      method = "POST", 
      data = '{"username":"' .. username .. '","text":"' .. message .. '", "channel":"' .. slackChannel .. '"}'
    },
    success = function(resp)
      if resp.status == 200 then
        fibaro:debug("It went well: " .. resp.status);
        fibaro:debug(message);
        print(resp.data);
      else
        
        fibaro:debug("SLACK REST error: " .. resp.status);
        print (resp.data);
        
      end
    end
    });

fibaro:setGlobal("slackMessage", "");  
fibaro:debug("end");