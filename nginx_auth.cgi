#!/usr/bin/env python
# -*- coding: UTF-8 -*-
import os
import socket
import sys
from flup.server.fcgi import WSGIServer
import logging
from typing import Final

SMTP_SERVER_NAME: Final = os.getenv('SMTP_SERVER', "localhost")
SMTP_PORT: Final = os.getenv('SMTP_PORT', "25")
SUBMISSION_SERVER_NAME: Final = os.getenv('SUBMISSION_SERVER', "localhost")
SUBMISSION_PORT: Final = os.getenv('SUBMISSION_PORT', "587")
IMAP_SERVER_NAME: Final = os.getenv('IMAP_SERVER', "localhost")
IMAP_PORT: Final = os.getenv('IMAP_PORT', "143")

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
        if not SMTP_SERVER_NAME:
            logging.error("SMTP_SERVER is not set")
        elif not SMTP_PORT:
            logging.error("SMTP_PORT is not set")
        else:
            logging.info(f'returning {SMTP_SERVER_NAME}:{SMTP_PORT}')
            headers.append(("Auth-Status", "OK"))
            headers.append(("Auth-Server", socket.gethostbyname(SMTP_SERVER_NAME)))
            headers.append(("Auth-Port", SMTP_PORT))

    if auth_protocol == "submission":
        if not SUBMISSION_SERVER_NAME:
            logging.error("SMTP_SERVER is not set")
        elif not SUBMISSION_PORT:
            logging.error("SMTP_PORT is not set")
        else:
            logging.info(f'returning {SUBMISSION_SERVER_NAME}:{SUBMISSION_PORT}')
            headers.append(("Auth-Status", "OK"))
            headers.append(("Auth-Server", socket.gethostbyname(SUBMISSION_SERVER_NAME)))
            headers.append(("Auth-Port", SUBMISSION_PORT))

    elif auth_protocol == "imap":
        if not IMAP_SERVER_NAME:
            logging.error("IMAP_SERVER is not set")
        elif not IMAP_PORT:
            logging.error("IMAP_PORT is not set")
        else:
            logging.info(f'returning {IMAP_SERVER_NAME}:{IMAP_PORT}')
            headers.append(("Auth-Status", "OK"))
            headers.append(("Auth-Server", socket.gethostbyname(IMAP_SERVER_NAME)))
            headers.append(("Auth-Port", IMAP_PORT))

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

WSGIServer(app, bindAddress='/var/run/fcgi/nginx_auth.sock').run()
