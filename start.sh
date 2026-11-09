#!/bin/sh
set -eu

python migrate.py
exec gunicorn --bind "0.0.0.0:${PORT:-5000}" --workers 1 --access-logfile - --error-logfile - app:app
