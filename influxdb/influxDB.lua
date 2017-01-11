--[[
%% properties
16 value
59 value
79 value
80 value
47 value
48 value
-- 16 entrance door
-- 59 basement door
-- 79 PIR m006 (on my desk)
-- 80 PIR m006 thermometer
-- 47 PIR m001 (living room)
-- 48 PIR m001 thermometer
%% events
%% globals
--]]

-- From Robert Carlsson: https://github.com/caguro/fibaro file: InfluxDB.lua

-- Function to escape invalid characters
function escChar(string)
  local data = string
  data = string.gsub(data, ",", "\\,")
  data = string.gsub(data, " ", "\\ ")
  data = string.gsub(data, "=", "\\=")
  return(data)
end

-- Define variables
local trigger = fibaro:getSourceTrigger()
local deviceID = tonumber(trigger['deviceID'])
local deviceName = escChar(fibaro:getName(deviceID))
local roomName = escChar(fibaro:getRoomNameByDeviceID(deviceID))
local roomID = fibaro:getRoomID(deviceID)
local triggerType = trigger['type']
local propertyName = trigger['propertyName']
local value = tonumber(fibaro:getValue(deviceID, propertyName))

-- Define your measurment
local measurement = "temperature"

-- Define your InfluxDB connection information
-- curl -G http://192.168.4.55:8086/query --data-urlencode "q=CREATE DATABASE hc2Wue"
-- curl -G 'http://192.168.4.55:8086/query?pretty=true' --data-urlencode "db=hc2Wue" --data-urlencode "q=SELECT * FROM temperature "
--
local influxDBIP = "192.168.4.55"
local influxDBPort = "8086"
local influxDBDatabase = "hc2Wue"
local influxDBTimeout = 2000

-- POST data to InfluxDB function
function influxDBPost(payload)
  --fibaro:debug("Calling HTTP POST to InfluxDB at "..influxDBIP..":"..influxDBPort) 
  fibaro:debug("Payload: " .. payload)

  local http = net.HTTPClient( {timeout=influxDBTimeout} )
  local url = "http://" .. influxDBIP .. ":" .. influxDBPort .. "/write?db=" .. influxDBDatabase
  http:request(url, {
      options = {
        method = 'POST',
        headers = {
          ["Content-Type"] = "text/plain"
        },
        data = payload,
        timeout = influxDBTimeout
      },
      success = function(result)
        local log = ""
        if (result.status ~= 204) then
          log = "Error while sending request. Status code: " .. result.status .. ", Body: " .. result.data
        elseif (result.status == 204) then
          log = "success"
        end
        --print(log)
      end,
      error = function(error)
        print('error: ' .. error)
      end
  })
  

end

-- Do the main processing
if ( trigger['type'] == 'property' ) then
  fibaro:debug('Property changed: ID=' .. deviceID .. " value=" .. value)

  -- Modify the payload veriable to suit your needs.
  local payload=measurement .. ",host=fibaro,deviceID=" .. deviceID .. ",deviceName=" .. deviceName .. ",roomID=" .. roomID ..",roomName=" .. roomName .. " value=" .. value
  influxDBPost(payload)

elseif ( trigger['type'] == 'global' ) then
  --fibaro:debug('Global changed')

elseif ( trigger['type'] == 'other' ) then
  --fibaro:debug('Other changed')

end

