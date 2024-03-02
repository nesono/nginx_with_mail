#!/bin/sh
set -e

/bin/bash /usr/local/bin/configure.sh
exec supervisord -c /etc/supervisor/supervisord.conf
