# Introduction

This directory contains two scenes for HC2:

* slack-trigger
* slack-send

The slack-trigger scene will trigger on an event of a device and set the global variable "slackMessage" to a message which will be sent by slack-send.
The slack-send scene will be triggered when the global variable "slackMessage" is changed, then connect to the Slack REST API using an API token that is stored in the global variable "slackKey". You get the Slack token at slack.com


# Installation

* Set up the global variables in Panels->Variable Panel
  * slackMessage -> a normal variable, set the initial value to 0
  * slackKey -> a predefined variable, set value1 to the slack api token. Set value2 to nothing.
  * slackUsername -> a predefined variable, set value1 to a username to be seen in the chat. Set value2 to nothing.
  * slackChannel -> a predefined variable, set value1 to the slack channel to post in. Set value2 to nothing.

* Copy/Paste the content of slack-send into a new scene that you for example call "slack-send"
* Copy/Paste the content of slack-trigger into a new scene that you for example call "slack-trigger"

## slack-send

Do not create this scene before you have created the global variables mentioned above. If the scene is not triggered bya change of the conetent of the slackMessage variable, just copy/paste the scene again and save it. The global variable slackMessage _has_ to exist before you save this scene.

In this scene, there are two variables that you should change to something that appeals to you:

```
username = "HC2";
slackChannel = "#hc2"
```

You can also set the global variables "slackUsername" and "slackChannel" to change the sender and slack channel.

## slack-trigger

* You will need to get the device IDs for the devices you intend to trigger.
* Replace the IDs in the scene with your IDs in the "properties" section

Example:

```
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
```

NOTE that there is a very annoying bug in the HC2 LUA scene, that the first value after "%% properties" cannot be commented out. If it is, the scene will not trigger at all.
