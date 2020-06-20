#!/bin/bash
export jkrnixrepo='https://api.github.com/repos/JWKoster/JKRnix/commits/master'

cd ${jkrnix}/self-updater/
wget -qO gitVersion.flat ${jkrnixrepo} --header="Accept: application/vnd.github.VERSION.sha"

if [ -z gitversion.flat ]
then echo "GIT: NULL" > gitVersion.flat
fi

if [ -z currentVersion.flat ]
then echo "CURRENT: NULL" > currentVersion.flat
fi

if [ "$(cat gitVersion.flat)" = "$(cat currentVersion.flat)" ] ; 
	then
		exit 0
	else	
		sh updater.sh
fi
cd -
