#!/bin/bash
#Use bash if available, to cause as few compatibility complications as possible
# ==================================================================== #
# Jelle Koster's Environment Settings, Scripts, Aliases, Libraries, ...
# based on the work of many others, found through extensive google-fu
# ==================================================================== #

#START_EXCLUDE_ALWAYS
# VS 2.0/01

 

# History:

# Version Date     		Who      Remarks

# 1.0/01  2020/09/01	JKR      Created base version to more easily and uniformly create scripts
# 2.0/01  2020/06/05	JKR		 Added functionality to create standalone scripts (-s), which can be deployed without dependency on jkrnix variables.
# 2.0/02  2020/06/06	JKR		 Added functionality to exclude parts of this script from the resulting file using START & END EXCLUDE ALWAYS/JKR/STANDALONE
# 2.0/03  2020/07/30	JKR		 Added create_myconfig function, purposely not through shlib so the heredoc can be changed per script
# 2.0/04  2021/08/16    JKR      Some polish on determining the log and cfg dir.
#END_EXCLUDE_ALWAYS
# ==================================================================== #
# VS 1.0/01


# History:

# Version Date     		Who      Remarks

# 1.0/01  YYYY/MM/DD 	JKR      Created base version to ...

# ==================================================================== #
# Globals

gMyName=$(basename ${0})

# Check if the script is in $PATH or not. Don't actually grep $PATH because of symlinks.
if hash ${gMyName} 2>/dev/null
	then #Use 'which' if it is a command, this is less complicated and performs better.
		gHome=$(dirname `which ${gMyName}`)
	else #This should be POSIXly correct. Sadly, in POSIX/BASH there seems to be no perfect answer to getting a script's home directory in 100% of all scenarios. Please let me know if you run into issues.
		gHome="$( cd "$( dirname "${0}" )" >/dev/null 2>&1 && pwd )"
fi

gSysDateTime=$(date +"%d_%m_%Y_%H_%M_%S")

if [ -z ${jkr} ]
        then
                if [ -d ~/jkr ]
                        then jkr=~/jkr/
                fi
fi

if [ ! -z ${jkr} ]
        then
                if [ -d ${jkr}/logs ]
                        then gLogDir=${jkr}/logs/
                        else mkdir ${jkr}/logs
                             gLogDir=${jkr}/logs/
                fi
        else gLogDir=$(mktemp -d) || exit 1
fi
gLog=${gLogDir}/${gMyName}_${gSysDateTime}.log

if [ ! -z "${jkr}" ]
        then gMyConfigFile=${jkr}/cfg/${gMyName%.*}.cfg
        elif [ -d ~/jkr ]
                then gMyConfigFile=~/jkr/cfg/${gMyName%.*}.cfg
        else warning "Cannot determine correct location for config dir. '${jkr}' or ~/jkr do not exist."
             warning "This is only a problem if this script uses a config file."
fi

#START_EXCLUDE_ALWAYS
gStandalone="false"
#END_EXCLUDE_ALWAYS

# ==================================================================== #
# Libraries

#START_EXCLUDE_STANDALONE
#Load libraries
JKR_LIBS="jkr_usage.shlib jkr_logging.shlib"
. ${jkr}/bin/jkr_load_lib.sh
#END_EXCLUDE_STANDALONE

# ==================================================================== #
# Functions

function create_myconfig()
{
# Create my own config file.
if [ ! -d ~/jkr ]
	then
		mkdir ~/jkr
		if [ ! -d ~/jkr/cfg ]
			then
				mkdir ~/jkr/cfg
		fi
fi
# Check if config file already exists:
if [ -f "${gMyConfigFile}" ]
then
        complain "Config file already exists. Aborting."
        return 1
fi

# Check if directory exists:
typeset tMyConfigDir=$(dirname ${gMyConfigFile})

if [ ! -d "${gMyConfigFile}" ]
then
        mkdir -p ${tMyConfigDir} || return 1
fi

# Now create the config file (remember to escape variables you want to be passed on using \ before $):
cat <<-EOC > ${gMyConfigFile}
# Configuration file ${gMyName}
exampleParameter="exampleString" #Describe the parameter
EOC

verbose "Config file created: ${gMyConfigFile}"
verbose "Change this config file first before continue the installation."
return 0
}


# ==================================================================== #
# Options and documentation

while getopts ":hvDs" Flag
#Some default flags
do

        case ${Flag} in
#		Put the # comment on the same line as the option to ensure the option is shown in the dynamic "usage" helptext!
# 		For example: h)      # displays this help
#		Only entries between #MANSTART and #MANEND are shown, which include those markers at the beginning of the line. You can use #MANSTART and #MANEND multiple times.
#		The commented out option letters are reserved, but not in use in the template script. Comment them back in and create some functionality if you want to use them.
#		-c comment this in if your script uses a config file. Add the heredoc in the function create_myconfig.
#       c)      # -c creates my config file
#                       create_myconfig
#                       exit $?
#                        ;;
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
#START_EXCLUDE_ALWAYS
				s)		#Creates a standalone script without dependency on jkrnix, inserting the libraries' current versions.
						gStandalone="true"
						verbose "Creating script as standalone."
						;;
#END_EXCLUDE_ALWAYS
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

#DOCSTART
#
#Document your script here!
#START_EXCLUDE_ALWAYS
#Documentation for jkr_template_script.sh:
# jkr_template_script.sh copies itself to your desired new script name, so it can serve as a basis for your new script.
# jkr_template_script.sh [TARGET FILE NAME]
# For example: jkr_template_script.sh copied.sh
#END_EXCLUDE_ALWAYS
#DOCEND

# ==================================================================== #
# Body

#START_EXCLUDE_ALWAYS
#Prevent losing work.
echo ${1}
if [ -f ${1} ]
	then 
		if ! confirm "${1} already exists, are you sure you want to overwrite?"
			then	
				exit 0
			else
				chmod 700 ${1}; rm ${1}
		fi
fi

cp ${gHome}/${gMyName} ${1}

#Clean up the workings of this script, and include the libraries in case it is standalone.
if [ ${gStandalone} = "true" ] 
	then 
		sed -i '/^\#START_EXCLUDE_STANDALONE/,/^\#END_EXCLUDE_STANDALONE/d' ${1}
		tmpFile=$(mktemp -p ${gLogDir}) || exit 1
		echo "#Start of imported libraries, to make this script standalone." >> ${tmpFile}
		echo "#It may not look pretty, but does allow a more flexible creation. Clean it up if you want." >> ${tmpFile}
		for i in ${JKR_LIBS}
		do cat ${jkr}/lib/${i} >> ${tmpFile}
		printf '\n' >> ${tmpFile}
		printf '\n' >> ${tmpFile}
		done
		echo "#End of imported libraries" >> ${tmpFile}
		sed -i "/^\# Libraries/r ${tmpFile}" ${1}
	else 
		sed -i '/^\#START_EXCLUDE_JKR/,/^\#END_EXCLUDE_JKR/d' ${1}
fi
sed -i '/^\#START_EXCLUDE_ALWAYS/,/^\#END_EXCLUDE_ALWAYS/d' ${1}

#Set permissions: jkrnix scripts should be adjusted through GIT, standalone scripts can be adjusted ad hoc.
if [ ${gStandalone} = "true" ]
	then chmod 710 ${1}
	else chmod 510 ${1}
fi

verbose "${1} has been created succesfully".
#END_EXCLUDE_ALWAYS