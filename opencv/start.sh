#!/bin/bash
source ~/.bashrc
RANDO=$(python -c 'import os; print(os.urandom(16))')
cd /usr/srv/app
printf "SECRET_KEY = %s" $RANDO > config.py
waitress-serve --call 'flaskr:create_app'
