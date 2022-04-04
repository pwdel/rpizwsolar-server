# syntax=docker/dockerfile:1
FROM debian:bullseye-slim

# install any system tools
RUN apt-get update                                              && \
    # install cron
    apt-get install -y --no-install-recommends                     \
        cron=3.0pl1-137                                            \
        nano=5.*                                                   \
        python3-pip=20.3.*                                      && \
    # clear the local repository of package files left in /var/cache
    apt-get clean                                               && \
    # /var/lib/apt stores all packages after apt-get update, it's unneeded bulk
    rm -rf /var/lib/apt/lists/*

# copy files from local directory
# includes getpostweather.py
COPY app /home/app

# move into the proper working directory where requirements.txt resides
WORKDIR /home/app

# Python installation of requirements with pip
# install python requirements.txt via binary
RUN apt-get update                                              && \
    pip3 install --no-cache-dir -r requirements.txt             && \
    # clear the local repository of package files left in /var/cache
    apt-get clean                                               && \
    # /var/lib/apt stores all packages after apt-get update, it's unneeded bulk
    rm -rf /var/lib/apt/lists/*

# make getpostweather.py executable a+x
RUN chmod a+x getpostweather.py
# add /home/app to path so we can execute scripts in here anywhere
RUN PATH=/home/app:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# add /home/app permanently to $PATH
RUN echo 'export PATH="/home/app/:$PATH"' >> ~/.bashrc

# Make Working Directory the Default Directory
WORKDIR /home

# setup cron job
# note - cron path includes # PATH=/home/app:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# copy cron job to /etc/cron.d/hourlyweather
COPY /cron/hourlyweather /etc/cron.d/hourlyweather
# make cron job executable
RUN chmod 0644 /etc/cron.d/hourlyweather
# apply cron job
RUN crontab /etc/cron.d/hourlyweather
# start the cron service
RUN update-rc.d cron defaults
RUN /etc/init.d/cron start
# message should show:
# Starting periodic command scheduler: cron.

# any other executable shell scripts

# entrypoints
