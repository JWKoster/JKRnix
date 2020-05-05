#!/bin/sh
## load_lib.sh
#	DESCRIPTION	:	Load and manage shell libraries
#	AUTHOR		:	AHL
#	Adjusted by JKR to prevent conflicts, and allow jkrnix reuse. Thanks, AHL!
#	ID		:	$Id: load_lib.sh 521 2017-11-07 16:29:27Z ahl $
#
#	DOCUMENTATION
#	---------------------------------------------------------------------------------------
#	This load_lib.sh can be used in scripts to safely load shell libraries.
#	The environment variable JKR_LIBPATH must be set up correctly (colon separated 
#	list of directories to search shlib files in)
##
#Scripts calling this should include the following at the beginning:
#JKR_LIBS="library1.shlib library2.shlib"
#. JKR_load_lib.sh

myself="load_lib.sh"

if [ -z "${JKR_LIBPATH}" ]; then
	if [ -d "${U_INSTALLROOT}/jkr/lib" ]; then
		JKR_LIBPATH="${U_INSTALLROOT}/jkr/lib"
	fi
fi

locate_lib()
{
	# find the library in searchpath
	local libpath=
	local located=false

	local ifs="${IFS}"; IFS=":"
	for dir in ${JKR_LIBPATH}
	do
		libpath="${dir}/${1}"
		if [[ -f ${libpath} ]]; then
			located=true
			break
		fi
	done
	IFS="${ifs}"

	if ${located}; then
		echo ${libpath}
		return 0
	else
		echo "library ${1} not found in ${JKR_LIBPATH}" >&2
		return 1
	fi
}

load_lib()
{
	local libpath=$(locate_lib "${1}")
	[ -n "${libpath}" ] || return

	local libvar=$(echo "${1}" | sed 's/\.shlib//')

	eval ${libvar}_loaded=true
	. ${libpath}
}

is_loaded()
{
	local libvar=$(echo "${1}" | sed 's/\.shlib//')_loaded
	eval \${${libvar}:-false}
}

load_lib_main()
{
	local sv_JKR_LIBS="${JKR_LIBS}"
	local libname=

	for libname in ${sv_JKR_LIBS}; do
		if ! is_loaded ${libname}; then
			load_lib ${libname}
		fi
	done
	JKR_LIBS="${sv_JKR_LIBS}"
}

load_lib_main
