#!/usr/bin/env bash

# exit the script if nonzero status
set -e

# ----> setup cron jobs
# we seem to need an entrypoint script to define the below
# make cron job executable to user but not to group or others
chmod 0644 /etc/cron.d/cron
echo "Completed: chmod 0644 /etc/cron.d/cron" >> /home/bin/entrypoint.results
# apply cron job
# there will be no response
crontab /etc/cron.d/cron
echo "Completed: crontab /etc/cron.d/cron" >> /home/bin/entrypoint.results
# update the cron defaults
# there should be no response
update-rc.d cron defaults
echo "Completed: update-rc.d cron defaults" >> /home/bin/entrypoint.results
# start periodic scheduler.
# response will be, "Starting periodic command scheduler: cron."
/etc/init.d/cron start
echo "Completed: /etc/init.d/cron start" >> /home/bin/entrypoint.results
echo "Cronjob should be started now." >> /home/bin/entrypoint.results
echo "---------------------------------" >> /home/bin/entrypoint.results
# export the datetime
export THEDATETIME="$(date)"
echo "Setup completed at $THEDATE ." >> /home/bin/entrypoint.results

# allow argument fed into entrypoint.sh to run to keep container up and running
exec "$@"