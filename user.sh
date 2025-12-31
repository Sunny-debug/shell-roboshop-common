#!/bin/bash

source ./common.sh
app_name=user

check_root
app_setup
Nodejs_setup
systemd_setup
app_restart
print_total_time