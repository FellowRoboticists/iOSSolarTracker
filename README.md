SolarTracker iOS App
====================

This iPhone app is to be used in conjunction with the solar_tracker
Arduino sketch/project. The app attempts to connect to the BLE shield
and treat the solar_tracker as a 'peripheral'.

When connected and in 'Light Sensing' mode, the app will display the
current servo positions and the current values for each of the LDR's
on the sensor.

When connected and the 'Light Sensing' mode is off, the app will still
display the servo positions and LDR values, but now you can use the
sliders and steppers to change the position of the servos.

Copyright
=========

Copyright (c) 2014 Dave Sieh

See LICENSE.txt for details.
