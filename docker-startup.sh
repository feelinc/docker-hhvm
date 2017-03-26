#!/bin/bash

chmod 600 /etc/cron.d/*
chown -R www-data:www-data /var/log/hhvm
chown -R www-data:www-data /var/www/*

rsyslogd & cron -L15 & supervisord -n