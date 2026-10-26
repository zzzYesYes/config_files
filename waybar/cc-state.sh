#!/bin/sh
if [ "$(cat /tmp/cc-visible 2>/dev/null)" = "1" ]; then
    printf '{"text": "%s", "class": "active"}\n' ""
else
    printf '{"text": "%s"}\n' ""
fi
