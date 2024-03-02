#!/usr/bin/env python
# -*- coding: UTF-8 -*-
import os
import socket
import sys
from flup.server.fcgi import WSGIServer
import logging
from typing import Final

SUBMISSION_SERVER_NAME: Final = os.getenv('SUBMISSION_SERVER', "localhost")
SUBMISSION_PORT: Final = os.getenv('SUBMISSION_PORT', "587")

AUTH_HTTP_DEBUG_LEVEL: Final = os.getenv('AUTH_HTTP_DEBUG_LEVEL', "INFO")


def app(environ, start_response):
    headers = [('Content-Type', 'text/html')]
    logging.debug('Received Request')

    logging.debug('Environ vars')
    for key, value in environ.items():
        logging.debug(f"{key} = {value}")
    logging.debug('\n')

    auth_user = environ.get("HTTP_AUTH_USER", "")
    auth_protocol = environ.get("HTTP_AUTH_PROTOCOL", "")

    logging.debug(f'user: {auth_user}, protocol: {auth_protocol}')

    if auth_protocol == "smtp":
        if not SUBMISSION_SERVER_NAME:
            logging.error("SUBMISSION_SERVER_NAME is not set")
        elif not SUBMISSION_PORT:
            logging.error("SUBMISSION_PORT is not set")
        else:
            logging.info(f'returning {SUBMISSION_SERVER_NAME}:{SUBMISSION_PORT}')
            headers.append(("Auth-Status", "OK"))
            headers.append(("Auth-Server", socket.gethostbyname(SUBMISSION_SERVER_NAME)))
            headers.append(("Auth-Port", SUBMISSION_PORT))
    else:
        logging.warning(f'Invalid protocol in request for user {auth_user}')
        headers.append(("Auth-Status", "Invalid"))
        headers.append(("Auth-Message", "Invalid protocol"))

    start_response('200 OK', headers)
    yield '\r\n'


def string_to_log_level(s: str):
    log_level_dictionary = {
        "DEBUG": logging.DEBUG,
        "INFO": logging.INFO,
        "WARNING": logging.WARNING,
        "ERROR": logging.ERROR,
        "CRITICAL": logging.CRITICAL
    }

    return log_level_dictionary.get(s, logging.INFO)


log_format = '%(asctime)s [%(levelname)s] %(message)s'
logging.basicConfig(level=string_to_log_level(AUTH_HTTP_DEBUG_LEVEL), format=log_format, stream=sys.stdout)

WSGIServer(app, bindAddress='/var/run/fcgi/nginx_submission_auth.sock').run()
