#!/bin/bash

if [ -n "${cwksbEnvironment}" ]
	then
		if [ "${cwksbEnvironment}" = 'dev' ]
			then

				echo "If this takes a long time, people haven't closed their calls properly. It'll still be looping."
				echo "Tp | NipPkg   | Src/Tab | Vs | Who | Date / Time         | Sts | Details"
				echo "---+----------+---------+----+-----+---------------------+-----+--------------------------"

				for call in $(call.sh query -s SRG | awk -F" " '{print $2}' | tail -n +3)
				do
				call_contents=$(call_logbook.sh ${call} | grep -v -e "Contents of logbook" -e 'Tp |' -e '---+' -e '|   5 |')
						if [ -n "${call_contents}" ]
								then
										echo "Contents of logbook for call ${call}"
										echo "${call_contents}"
						fi
				done
			else
				echo "This script is only for LSP dev environments"
		fi
	else
		echo "This script is only for LSP environments"
fi