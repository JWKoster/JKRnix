wget -qO ~/jkrnix.tar.gz https://github.com/JWKoster/JKRnix/tarball/master || exit 1
tar -xzf ~/jkrnix.tar.gz --strip-components=1 && rm ~/jkrnix.tar.gz
wget -qO currentVersion.flat https://api.github.com/repos/JWKoster/JKRnix/commits/master --header="Accept: application/vnd.github.VERSION.sha"
ln -s ${jkrnix}bin/*.sh ${jkr}bin/
ln -s ${jkrnix}lib/*.shlib ${jkr}lib/
