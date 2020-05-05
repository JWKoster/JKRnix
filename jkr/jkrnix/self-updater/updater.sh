wget -qO jkrnix.tar.gz https://github.com/JWKoster/JKRnix/tarball/master || exit 1
tar -xzvf jkrnix.tar.gz --strip-components=1 && rm jkrnix.tar.gz
wget -qO currentVersion.flat https://api.github.com/repos/JWKoster/JKRnix/commits/master --header="Accept: application/vnd.github.VERSION.sha"
