#!bin/bash
if [ ! -f /var/spool/cron/crontabs/root.bak ]; then 
  cp /var/spool/cron/crontabs/root /var/spool/cron/crontabs/root.bak; 
fi
rm /var/spool/cron/crontabs/root
cp /var/spool/cron/crontabs/root.bak /var/spool/cron/crontabs/root
echo "$TIMING cd /app/ && bash cf_ddns.sh" >> /var/spool/cron/crontabs/root
crond