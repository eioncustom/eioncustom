#!/bin/bash

#Prequisties:
#Google Chrome or Edge, this is written around Chrome but the scoreboard system requires either and does not function properly in Safari and IE.

#This sleep may be arbitrary, just giving the kernel some time to settle before starting services.
sleep 5

#Ensure the user executing this has sudo nopasswd permissions.
sudo <Directory to Scoreboard>/scoreboard.sh&sleep 5;google-chrome <Directory to Scoreboard>/crg-scoreboard_v2023.4/start.html

#This has been tested on Ubuntu 20.04 LTS
