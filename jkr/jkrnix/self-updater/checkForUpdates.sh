wget -qO gitVersion.flat https://api.github.com/repos/JWKoster/JKRnix/commits/master --header="Accept: application/vnd.github.VERSION.sha"

if [ `cat gitVersion.flat` = `cat currentVersion.flat` ] ; 
	then
		exit 0
	else	
		sh updater.sh
fi
