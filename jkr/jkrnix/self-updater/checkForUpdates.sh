#!/bin/bash
JKR_LIBS="jkr_logging.shlib"
. ${jkrnix}/bin/jkr_load_lib.sh

export jkrnixrepo='https://github.com/JWKoster/JKRnix/tarball/master'
export jkrnixrepoversion='https://api.github.com/repos/JWKoster/JKRnix/commits/master'

if [ -z ${jkrnix}/self-updater/gitversion.flat ]
then echo "GIT: NULL" > ${jkrnix}/self-updater/gitVersion.flat
fi

if [ -z currentVersion.flat ]
then echo "CURRENT: NULL" > ${jkrnix}/self-updater/currentVersion.flat
fi

cd ${jkrnix}/self-updater/
wget -qO ${jkrnix}/self-updater/gitVersion.flat ${jkrnixrepoversion} --header="Accept: application/vnd.github.VERSION.sha"

if [ "$(cat ${jkrnix}/self-updater/gitVersion.flat)" = "$(cat ${jkrnix}/self-updater/currentVersion.flat)" ] ;
        then
        echo "JKRnix is active. No updates to be done. Enjoy!"
            exit 0
        else
        if confirm "JKRnix: There's an update available. Do you want to update? Y/N"
                then
                sh updater.sh && echo "JKRnix updated to the latest version. Enjoy!"
        fi

fi
