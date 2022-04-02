# syntax=docker/dockerfile:1
FROM debian:bullseye-slim

# install any system tools
RUN apt-get update                                              && \
    # install cron
    apt-get install -y --no-install-recommends                     \
        cron=3.0pl1-137                                            \
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
    pip3 install -r requirements.txt                            && \
    # clear the local repository of package files left in /var/cache
    apt-get clean                                               && \
    # /var/lib/apt stores all packages after apt-get update, it's unneeded bulk
    rm -rf /var/lib/apt/lists/*

# add python weather grabbing script to bash to make it visible to all apps

# setup cron job


# execute cron job

# any executable shell scripts


# entrypoints
