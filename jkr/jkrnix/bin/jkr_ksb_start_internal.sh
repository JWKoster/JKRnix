#!/bin/bash

# VS 1.0/01

# History:
# Version Date       Who Remarks
# 1.0/01  22-04-2020 JKR Created script to start mule from cron on internal environments. This is only intended for environments in active use, if not in active use please comment out the cronjob. 

#Globals
gMyName=$(basename ${0})
gHome=${U_CWKSBHOME}
gSysDateTime=$(date +"%d_%m_%Y_%H_%M_%S")
gLog=${gHome}/logs/${gMyName}.log

#Functions
usage()
{
       cat << EOU
usage : ${gMyName} [ -d yyyymmdd ]

Current version: $(grep "^# VS" ${0} |cut -c6-)

Function:
Start mule from cron on internal environments. 
This is only intended for environments in active use, if not in active use please comment out the cronjob.

Sample cronjob:
#Start KSB each monday morning. This should be turned off after the project is finished and KSB is no longer under active development.
30 6 * * MON . ${HOME}/.unims; usu $USER nohup ${HOME}/jkr/bin/jkr_ksb_start_internal.sh > ${U_CWKSBHOME}/logs/jkr_ksb_start_internal_cron.log 2>&1 &

Mandatory flags:
None

Optional flags:
-h      : This help.
EOU
}

function verbose()
{
cd ${gHome} || exit
if ! -d ${gHome}logs &>/dev/null;
then true
else
        mkdir logs
fi

        typeset iLine=${1}
        typeset iCurDateTime=$(date +"%d_%m_%Y_%H_%M_%S")
        echo "${iCurDateTime}: ${iLine}"
        echo "${iCurDateTime}: ${iLine}" >> ${gLog}
}

# Check and handle flags
while getopts ":h" Flag
do
        case ${Flag} in
	h)
                usage
                exit
		;;
        *)
        #In case of undefined flags
                echo "You used an undefined flag, refer to -h for usage"
                exit
esac
done

mule-server.sh start
