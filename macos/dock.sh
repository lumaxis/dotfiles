#!/bin/sh

is-executable dockutil || brew install dockutil

dockutil --no-restart --remove all
dockutil --no-restart --add "/System/Applications/App Store.app"
dockutil --no-restart --add "/System/Applications/Launchpad.app"
dockutil --no-restart --add "/Applications/Microsoft Edge Beta.app"
dockutil --no-restart --add "/Applications/Spark.app"
dockutil --no-restart --add "~/Applications/Edge Beta App.localized/Outlook.app"
dockutil --no-restart --add "/Applications/Things3.app"
dockutil --no-restart --add "/Applications/Fantastical.app"
dockutil --no-restart --add "/Applications/Spotify.app"
dockutil --no-restart --add "/System/Applications/TV.app"
dockutil --no-restart --add "/Applications/Tweetbot.app"
dockutil --no-restart --add "/Applications/Twitter.app"
dockutil --no-restart --add "/Applications/Slack.app"
dockutil --no-restart --add "/Applications/zoom.us.app"
dockutil --no-restart --add "/Applications/Microsoft Teams.app"
dockutil --no-restart --add "/Applications/Skype.app"
dockutil --no-restart --add "/Applications/WhatsApp.app"
dockutil --no-restart --add "/Applications/Telegram.app"
dockutil --no-restart --add "/System/Applications/Messages.app"
dockutil --no-restart --add "/Applications/Visual Studio Code - Insiders.app"
dockutil --no-restart --add "/Applications/Tower.app"
dockutil --no-restart --add "/Applications/iTerm.app"

killall Dock
