# Introduction

The triggering devices are 3 motion sensors and a door sensor that is connected to the office door lock.

The triggering devices are configured in the "%% properties" section.
The lights are configured in the "lights" array.

* If any motion sensor senses a motion, we should re-set the timer (global variable "officeLightsTimer") to the lightsOnTime (default 1200 seconds)
* We ignore any motion sensor that sends a deviceValue of 0, since we turn off the light when the timer reach 0
* If the door is locked, the motion sensors should be ignored.
* When the door locks all lights should be shut off, and any instance of this scene should be terminated.
* This scene is actually a long running scene, ca 1200 seconds.
* Any time the scene is re-entered, it checks if there is another scene running. If yes, it just re-sets the timer (global variable) and exits.
* In the long running loop, we are constantly polling the global variable to catch if another invocation of the scene has re-set the timer.
* At the end of the scene, the lights are turned off.

