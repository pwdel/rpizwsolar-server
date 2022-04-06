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
# add /home/app and /home/bin to path so we can execute scripts in here anywhere
RUN PATH=/home/app:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# add /home/app permanently to $PATH
RUN echo 'export PATH="/home/app/:$PATH"' >> ~/.bashrc

# Make Working Directory the Default Directory for logging in under tty
WORKDIR /home

# setup cron job
# note - cron path includes # PATH=/home/app:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# copy cron job to /etc/cron.d/hourlyweather
COPY /cron/hourlyweather /etc/cron.d/cron

# copy entrypoint over into /home/binary files and make executable
COPY /bin/entrypoint.sh /home/bin/entrypoint.sh
# make getpostweather.py executable a+x
RUN chmod a+x /home/bin/entrypoint.sh

# entrypoints
#  if you use ENTRYPOINT and CMD together, then CMD becomes an argument for ENTRYPOINT.
#  ENTRYPOINT ["/app/entrypoint"] used in conjunction with CMD ["/app/start"] would be equivalent to:
#  user@container: /app/entrypoint /app/start
#  with /app/start being an argument being passed into /app/entrypoint
#  the purpose of entrypoint is to start the environment, while "start" would be to start a process
#  in Docker, Entrypoint and CMD are basically the same but in k8s, they need to be seperate as
#  with "CMD" serving as an argument into ENTRYPOINT
#  note, the actual entrypoint.sh script must include exec "$@" at the end to run that argument.

# set environment variables, start cron job, argument in json format
ENTRYPOINT ["/home/bin/entrypoint.sh"]
# run foreground process to keep container running
CMD tail -f /dev/null