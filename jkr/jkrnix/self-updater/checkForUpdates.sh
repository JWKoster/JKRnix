#!/bin/bash
cd ${jkrnix}/self-updater/
wget -qO gitVersion.flat https://api.github.com/repos/JWKoster/JKRnix/commits/master --header="Accept: application/vnd.github.VERSION.sha"

if [ -n gitversion.flat ]
then echo "GIT: NULL" > gitVersion.flat
fi

if [ -n currentVersion.flat ]
then echo "CURRENT: NULL" > currentVersion.flat
fi

if [ `cat gitVersion.flat` = `cat currentVersion.flat` ] ; 
	then
		exit 0
	else	
		sh updater.sh
fi
cd -
