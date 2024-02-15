#!/bin/sh
set -ex

exec supervisord -c /etc/supervisor/supervisord.conf
