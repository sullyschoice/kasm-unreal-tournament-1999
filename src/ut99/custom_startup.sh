#!/usr/bin/env bash
set -ex
START_COMMAND="/opt/ut99/launch.sh"
PGREP="ut-bin-amd64"
export MAXIMIZE="false"
export MAXIMIZE_NAME="ut-bin-amd64"
MAXIMIZE_SCRIPT=$STARTUPDIR/maximize_window.sh
DEFAULT_ARGS=""

ARGS=${APP_ARGS:-$DEFAULT_ARGS}


FORCE=$2

kasm_startup() {

    if [ -z "$DISABLE_CUSTOM_STARTUP" ] ||  [ -n "$FORCE" ] ; then

        echo "Entering process startup loop"
        set +x
        while true
        do
            if ! pgrep -x $PGREP > /dev/null
            then
                /usr/bin/filter_ready
                /usr/bin/desktop_ready
                set +e
                bash ${MAXIMIZE_SCRIPT} &
                $START_COMMAND $ARGS $URL
                set -e
            fi
            sleep 1
        done
        set -x

    fi
}

kasm_startup
