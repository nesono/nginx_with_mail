#!/bin/sh
set -ex

/bin/bash /usr/local/bin/configure.sh
exec supervisord -c /etc/supervisor/supervisord.conf
