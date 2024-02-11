#!/bin/sh
set -ex

exec supervisord -c /etc/supervisord.conf
