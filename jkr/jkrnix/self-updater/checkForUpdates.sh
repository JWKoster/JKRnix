#!/bin/bash

export jkrnixrepo='https://github.com/JWKoster/JKRnix/tarball/master'
export jkrnixrepoversion='https://api.github.com/repos/JWKoster/JKRnix/commits/master'

if [ -z gitversion.flat ]
then echo "GIT: NULL" > gitVersion.flat
fi

if [ -z currentVersion.flat ]
then echo "CURRENT: NULL" > currentVersion.flat
fi

cd ${jkrnix}/self-updater/
wget -qO gitVersion.flat ${jkrnixrepoversion} --header="Accept: application/vnd.github.VERSION.sha"

if [ "$(cat gitVersion.flat)" = "$(cat currentVersion.flat)" ] ; 
	then
		exit 0
	else	
		sh updater.sh
fi
