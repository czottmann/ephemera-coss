#!/bin/bash

sleep 1

cd '%APP_SUPPORT_DIR%'

TOUCH=".lock"

if [[ ! -e $TOUCH ]]; then
  touch $TOUCH

  sleep 2
  MF_NEW="mounts.new"
  MF_OLD="mounts.old"

  mount > $MF_NEW

  if [[ `diff $MF_OLD $MF_NEW | grep "^> \/" | grep -F "on %DEVICE_PATH% ("` != "" ]]; then

    STATUS=`/usr/bin/osascript <<EOSCRIPT

      tell application "Finder"
        activate
        set dIcon to POSIX file "%PATH%/Contents/Resources/Ephemera.icns"
        set dDesc to "Ephemera will start syncing your reader in 5 seconds."
        set dTitle to "Ephemera"

        try
          display dialog dDesc buttons {"Cancel"} default button 1 with title dTitle with icon dIcon giving up after 5
        on error number -128
          return "stop"
        end try

        return "go"
      end tell
EOSCRIPT
`

    if [[ "$STATUS" == "go" ]]; then
        AUTORUN=1 open "%PATH%"
      fi
  fi

  mv $MF_NEW $MF_OLD
  rm -f $TOUCH
fi
