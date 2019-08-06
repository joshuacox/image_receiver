#!/bin/bash
source ~/.bashrc
RANDO=$(python -c 'import os; print(os.urandom(16))')
printf "SECRET_KEY = %s" $RANDO > config.py
waitress-serve --call 'flaskr:create_app'
