#!/bin/bash
#Use bash if available, to cause as few compatibility complications as possible
# ==================================================================== #
# Jelle Koster's Environment Settings, Scripts, Aliases, Libraries, ...
# based on the work of many others, found through extensive google-fu
# ==================================================================== #

# VS 1.0/01

 

# History:

# Version Date     		Who      Remarks

# 1.0/01  YYYY/MM/DD JKR        Created base version to ...

#Load libraries
JKR_LIBS="jkr_usage.shlib jkr_logging.shlib"
. ${jkr}/bin/jkr_load_lib.sh

#Globals

gMyName=$(basename ${0})
gHome=$( cd “$(dirname “$0”)” >/dev/null 2>&1 ; pwd -P )
gSysDateTime=$(date +"%d_%m_%Y_%H_%M_%S")
gLogDir=${jkr}/logs/
gLog=${gLogDir}/${gMyName}_${gSysDateTime}.log


# ==================================================================== #
# Options and manual
# ==================================================================== #
while getopts ":hvD" Flag
#Some default flags
do

        case ${Flag} in
				#		Put the # comment on the same line as the option to ensure the option is shown in the dynamic "usage" helptext!
				# 		For example: h)      # displays this help
				#		Only entries between #MANSTART and #MANEND are shown. You can use #MANSTART and #MANEND multiple times.
				#		The commented out option letters are reserved, but not in use in the template script. Comment them back in and create some functionality if you want to use them.
                #       c)      # -c creates my config file, comment this in if your script uses a config file.
                        #               create_myconfig
                        #               exit $?
                        #                ;;
				#		q)      # Ssshh! Quiet.
				#				# Create some functionality to prevent output that is not caused by -v to go to the logfile, if you want to support a quiet mode. Maybe add it back into the library in GIT :)
				#		unset_verbose
                #		;;
                #MANSTART
                h)      # displays this help
                        usage
                        exit
                        ;;
                v)      # Verbose!
                        set_verbose
                        ;;
                
                D)      # Debug to stderr, same as "sh -x"
                        set -x
                        ;;
                #MANEND
                \?)     # Unknown option!
                        complain "Invalid option: -${OPTARG}"
                        exit 1
                        ;;
                :)      # Option without required argument
                        complain "Option -${OPTARG} requires an argument."
                        exit 1
                        ;;
        esac
done
        # Now shift all flagged parameters to receive the non flagged values as input
   shift $((OPTIND-1))

#HELPSTART#
#
#Document your script here!
#Documentation for jkr_template_script.sh:
# jkr_template_script.sh copies itself to your desired new script name, so it can serve as a basis for your new script.
# jkr_template_script.sh [TARGET FILE NAME]
# For example: jkr_template_script.sh copied.sh
#HELPEND
# ==================================================================== #

# ==================================================================== #
# Functions
# ==================================================================== #

# ==================================================================== #
# Body
# ==================================================================== #
echo ${1}
if [ -n ${1} ]
	then 
		if ! confirm "${1} already exists, are you sure you want to overwrite?: "
			then	
				exit 0
		fi
fi

cp $gHome/${gMyName} ${1}
