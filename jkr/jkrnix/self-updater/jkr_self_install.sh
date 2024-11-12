#!/bin/bash
#Use bash if available, to cause as few compatibility complications as possible
# ==================================================================== #
# Jelle Koster's Environment Settings, Scripts, Aliases, Libraries, ...
# based on the work of many others, found through extensive google-fu
# ==================================================================== #

# ==================================================================== #
# VS 1.0/01


# History:

# Version Date     		Who      Remarks

# 1.0/01  YYYY/MM/DD 	JKR      Created base version to install jkrnix on a new environment.

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
if [ -d ${jkr}/logs ] 
then gLogDir=${jkr}/logs/
else gLogDir=$(mktemp -d) || exit 1
fi
gLog=${gLogDir}/${gMyName}_${gSysDateTime}.log

# ==================================================================== #
# Libraries
#Start of imported libraries, to make this script standalone.
#It may not look pretty, but does allow a more flexible creation. Clean it up if you want.
##  jkr_usage.shlib
#	DESCRIPTION	:	function library to generate a unified automatic helptext based on comment logging, marked by one or more occurrences of #MANSTART, #MANEND, #DOCSTART and #DOCEND.
#	AUTHOR		:	Jelle Koster
#	Version		:	2020-05-09 JKR
#
#	PROVIDES
#	---------------------------------------------------------------------------------------
#	usage		:	Generic template for -h help text for script
##

usage()

{
	echo "This is the helptext for ${gMyName}."
	echo "Current version: $(grep -m 1 "^# VS" ${0} |cut -c6-)"
	echo
	#Retrieve arguments
	echo "The possible arguments are as follows.
	Please note options followed by a semicolon (:) expect an argument."
	grep getopts ${0} | awk -F'["]' '{print $2}' | sed -r 's/([[:alpha:]])/ -\1/g'
	echo
	#Read arguments
	echo "The arguments are documented as follows:"
	#First take out the marked sections. Then strip the top and bottom line. Then only take the lines marked as comment. Then strip leading non-alphanumeric characters for readability, then remove lines marked to exclude.
	#JKR_TODO: Perhaps one day, an improvement would be to somehow not display commented out code. For now, recommendation is to remove unused code from the options.
	sed -n -e '/^\#MANSTART/,/^\#MANEND/ p' ${0} | tail -n +2 | head -n -1 | grep '#' | sed 's/^[^[:alnum:]]*//' | grep -v EXCLUDE
		echo
			#Read documentation
			echo "Further documentation (if any):"
			sed -n -e '/^\#DOCSTART/,/^\#DOCEND/ p' ${0} | tail -n +2 | head -n -1 | grep '#' | sed 's/^[^[:alnum:]]*//' | grep -v EXCLUDE
				echo
							echo "Good luck!"
						}

##  jkr_logging.shlib
#	DESCRIPTION	:	function library to log messages
#	AUTHOR		:	AHL
#	Adjusted by JKR. Thanks, AHL!
#
#	PROVIDES
#	---------------------------------------------------------------------------------------
#	complain		:	complain to the user through stderr (adds stack info)
#	warning     	:	warn the user through stderr (adds stack info)
#	verbose			:	only say something if the verbose flag is set
#	verbose2		:	same as verbose, but output to stderr
#	set_verbose		:	turn on the verbose flag (so 'verbose' does something)
#	unset_verbose	:	turn off the verbose flag
#	set_gLog		:	set log file, which will contain all the complaints and verbose logging
#	unset_gLog		:	stop logging in the log file
#	confirm         :	ask for confirmation from the user
##

logging_verbose="false" #to be set by -v
gLog="" #To be set by the calling script as the full path including filename

export JKR_RED=$(printf '\e[38;5;101m')
export JKR_YELLOW=$(printf '\e[38;5;103m')
export JKR_CLEAR_ATTR=$(printf '\e[0m')

complain()
{
	## complain
	#	complains to the user through stderr
	#	usage as you would use echo
	##
	echo "${JKR_BOLD_RED}error:${JKR_CLEAR_ATTR} ${FUNCNAME[1]}: "$(caller | awk '
	function bn(p) {
	n=split(p, a, "/");
	return a[n];
}

{ printf("%s (%d)",bn($2),$1) }'): "${JKR_BOLD_RED}${@}${JKR_CLEAR_ATTR}" >&2

	if [ -n "${gLog}" ]; then
		typeset iCurDateTime=$(date +"%Y_%m_%d_%H_%M_%S")
		echo "${iCurDateTime} - ERROR:  ${FUNCNAME[1]}: "$(caller | awk '{ printf("%s (%d)",$2,$1) }'): "$@" >> "${gLog}"
	fi		
}

warning()
{
	## warning
	#	warns the user through stderr
	#	usage as you would use echo
	##
	echo "${JKR_BOLD_MAG}warning:${JKR_CLEAR_ATTR} ${FUNCNAME[1]}: "$(caller | awk '
	function bn(p) {
	n=split(p, a, "/");
	return a[n];
}

{ printf("%s (%d)",bn($2),$1) }'): "${JKR_BOLD_MAG}${@}${JKR_CLEAR_ATTR}" >&2

	if [ -n "${gLog}" ]; then
		typeset iCurDateTime=$(date +"%Y_%m_%d_%H_%M_%S")
		echo "${iCurDateTime} - WARNING: ${FUNCNAME[1]}: "$(caller | awk '{ printf("%s (%d)",$2,$1) }'): "$@" >> "${gLog}"
	fi		
}

verbose()
{
	## verbose
	#	only say something if the verbose flag is set
	#	use as you would use echo
	##
	${logging_verbose} && echo "$@"
	if [ -n "${gLog}" ]; then
		typeset iCurDateTime=$(date +"%Y_%m_%d_%H_%M_%S")
		echo "${iCurDateTime} - INFO: $@" >> "${gLog}"
	fi
}

verbose2()
{
	## verbose
	#	yak through stderr
	##
	${logging_verbose} && echo "$@" >&2
	if [ -n "${gLog}" ]; then
		typeset iCurDateTime=$(date +"%Y_%m_%d_%H_%M_%S")
		echo "${iCurDateTime} - INFO: $@" >> "${gLog}"
	fi
}

set_verbose()
{
	## set_verbose
	#	turn on the verbose flag
	##
	export logging_verbose=true
}

unset_verbose()
{
	## unset_verbose
	#	turn off the verbose flag
	##
	logging_verbose=false
}

set_gLog()
{
	## set_gLog
	#	turn on logging to a logfile
	##
	gLog="${1}"
}

unset_gLog()
{
	## unset_gLog
	#	turn off logging to a logfile
	##
	gLog=""
}

confirm()
{
	local question="${1}"
	local ans

	while true; do
		echo "${question}"
		printf 'Please enter Y(es) or N(o): '
		read ans

		if echo "${ans}" | egrep -qi '^y(es)?$'; then
			return 0
		fi

		if echo "${ans}" | egrep -qi '^n(o)?$'; then
			return 10
		fi

		echo "Invalid input ... please retry"
	done
	return 10
}


#End of imported libraries

# ==================================================================== #
# Functions
installedCheck()
{
if [ ! -z ${envFile} ] ; 
	then 
		if grep -q jkrnix ${envFile} 2>/dev/null ;
			then 
				installed=true ; 
			else
				installed=false ;
		fi
	else echo "${envFile} not set"
fi
}

determineEnv()
{
if [ -f ~/etc/psd.cfg ]
        then
                LSPenv="dev"
        else
                LSPenv="NULL"
fi

if [ ${LSPenv} = 'dev' ]
	then
		envFile=~/etc/jkr.cfg
		installedCheck
#	elif [ -f ~/.bash_profile ] ;
#	then
#		envFile=~/.bash_profile
#		installedCheck
#	else
#		if [ -f ~/.bashrc ] ;
#			envFile=~/.bashrc
#		then
#			installedCheck
#		else
#			if [ -f ~/.unims ] ;
#				envFile=~/.unims
#			then
#				installedCheck
#			else
#				if [ -f ~/.profile ] ;
#					envFile=~/.profile
#				then
#					installedCheck
#				fi
#
#			fi
#
#		fi

fi
}

installJkrnix()
{
cd ~ ;
#GIT already contains jkr as first dir, no need to add it here
wget -qO jkrnix.tar.gz https://github.com/JWKoster/JKRnix/tarball/master ;
tar -xzf jkrnix.tar.gz --strip-components=1 && rm jkrnix.tar.gz ;

cd ~/jkr/jkrnix/self-updater/
wget -qO currentVersion.flat https://api.github.com/repos/JWKoster/JKRnix/commits/master --header="Accept: application/vnd.github.VERSION.sha" ;

ln -sf ~/jkr/jkrnix/bin/*.sh ~/jkr/bin/ ;
ln -sf ~/jkr/jkrnix/lib/*.shlib ~/jkr/lib/ ;
ln -sf ~/jkr/jkrnix/dot/.* ~/jkr/dot/ 2>/dev/null;
if [ ! -z ${envFile} ]
	then
		ln -sf ~/jkr/jkrnix/cfg/jkr.cfg ${envFile}
	else 
		echo "envFile is not set - manually ensure jkrnix is automagically started."
fi
}

# ==================================================================== #
# Options and documentation

while getopts ":hmvD" Flag
	#Some default flags
do

	case ${Flag} in
		#		Put the # comment on the same line as the option to ensure the option is shown in the dynamic "usage" helptext!
		# 		For example: h)      # displays this help
		#		Only entries between #MANSTART and #MANEND are shown, which include those markers at the beginning of the line. You can use #MANSTART and #MANEND multiple times.
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
	m)      # Manual - only provide commands to manually install jkrnix without ssh-ing
		declare -f installJkrnix
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

#DOCSTART
#
#This script installs jkrnix: Jelle Koster's own Unix environment settings & toolset.
#DOCEND


# ==================================================================== #
# Body

determineEnv

case ${installed} in
	true) echo "jkrnix already to be loaded through ${envFile}" ;;
	false) echo "Installing jkrnix" ;
			installJkrnix
esac
