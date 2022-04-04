# syntax=docker/dockerfile:1
FROM debian:bullseye-slim

# install any system tools
RUN apt-get update                                              && \
    # install cron
    apt-get install -y --no-install-recommends                     \
        cron=3.0pl1-137                                            \
        nano=5.4                                                   \
        python3-pip=20.3.*                                      && \
    # clear the local repository of package files left in /var/cache
    apt-get clean                                               && \
    # /var/lib/apt stores all packages after apt-get update, it's unneeded bulk
    rm -rf /var/lib/apt/lists/*

# copy files from local directory
COPY app /home/app

# move into the proper working directory
WORKDIR /home/app

# Python installation of requirements with pip
# install python requirements.txt via binary
RUN apt-get update                                              && \
    pip3 install --no-cache-dir -r requirements.txt             && \
    # clear the local repository of package files left in /var/cache
    apt-get clean                                               && \
    # /var/lib/apt stores all packages after apt-get update, it's unneeded bulk
    rm -rf /var/lib/apt/lists/*

# Make Working Directory the Default Directory
WORKDIR /home

# add python weather grabbing script to bash to make it visible to all apps

# setup cron job

# make getpostweather.py executable with a+x
# add /home/app to $PATH
# PATH=/home/app:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# add /home/app permanently to $PATH
# edit ~/.bashrc
# export PATH="/home/app/:$PATH"

# add path to cron job
# PATH=/home/app:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# the idea is that all you should have to enter anywhere is, "getpostweather.py" and it should work

# add actual script to cronjob
# 1 * * * * getpostweather.py

# start the cron service
# update-rc.d cron defaults
# /etc/init.d/cron start
# message should show:
# Starting periodic command scheduler: cron.

# to verify cron env, we can do:
# # post cron's understanding of env every minute
# * * * * * env > /tmp/env.output
# if you want a different default home directory for cron outputs, set HOME in crontab
# HOME=/root by default


# execute cron job

# any other executable shell scripts

# entrypoints
