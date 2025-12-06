#!/bin/bash

while true; do
    osascript -e 'tell application "System Events" to display dialog "This is a joke message! Your system is fine." buttons {"OK"} default button "OK"' with timeout 10
    sleep 300
done
