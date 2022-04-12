#!/bin/bash --login

# Service watchdog script
# Put in crontab to automatially restart services (and optionally email you) if they die for some reason.
# Note: You need to run this as root otherwise you won't be able to restart services.
#
# Example crontab usage:
#
# Strict check for apache2 service every 5 minutes, pipe results to /dev/null
# */5 * * * * sh /root/watchdog.sh apache2 "" > /dev/null
#
# "Loose" check for mysqld every 5 minutes, second parameter is the name of the service
# to restart, in case the application and service names differ. Also emails a report to admin@domain.com
# about the restart.
# */5 * * * * sh /root/watchdog.sh mysqld mysql admin@domain.com > /dev/null
 
# Common daemon names:
# Apache:
# apache2 - Debian/Ubuntu
# httpd - RHEL/CentOS/Fedora
# ---
# MySQL:
# mysql - Debian/Ubuntu
# mysqld - RHEL/CentOS/Fedora
# ---
# Service name
DATE=`date +%Y-%m-%d--%H-%M-%S`
SERVICE_NAME="coleta_storage.sh"
SERVICE_RESTARTNAME=""
EXTRA_PGREP_PARAMS="-x" #Extra parameters to pgrep, for example -x is good to do exact matching
MAIL_TO="youremail@youdomain.com" #Email to send restart notifications to
  
#path to pgrep command, for example /usr/bin/pgrep
PGREP="pgrep"
pids=`(ps -aux | grep $SERVICE_NAME | grep -v grep | cut -d' ' -f2)`
echo "pid" 
echo $pids
#if we get no pids, service is not running
if [ "$pids" == "" ]
then
/opt/storage/coleta_storage.sh &
pids=`(ps -aux | grep $SERVICE_NAME | grep -v grep | cut -d' ' -f2)`
echo "pid"
echo $pids

 if [ -z $MAIL_TO ]
   then
     echo "$DATE : ${SERVICE_NAME} reiniciado, sem e-mail configurado"
   else
     echo "$DATE : reiniciando o servico: ${SERVICE_NAME} "
 fi
else
  echo "$DATE : Service ${SERVICE_NAME} ainda rodando!"
fi

