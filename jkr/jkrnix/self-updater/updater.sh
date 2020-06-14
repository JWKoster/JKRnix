#!/bin/bash
jkrnix_install() 
{
wget -qO ~/jkrnix.tar.gz https://github.com/JWKoster/JKRnix/tarball/master || exit 1
tar -xzf ~/jkrnix.tar.gz --strip-components=1 -C ~/ && rm ~/jkrnix.tar.gz
wget -qO currentVersion.flat https://api.github.com/repos/JWKoster/JKRnix/commits/master --header="Accept: application/vnd.github.VERSION.sha"
}

jkrnix_symlinks() 
{
for sh in $(find ${jkrnix}/bin/ -type f -name "*.sh" ! -name "*.swp")
do
	ln -sf ${sh} ${jkr}bin/
done

for shlib in $(find ${jkrnix}/shlib/ -type f -name "*.shlib" ! -name "*.swp")
do
	ln -sf ${shlib} ${jkr}lib/
done
}

for dot in $(find ${jkrnix}/dot/ -type f -name ".*" ! -name "*.swp")
do
	ln -sf ${dot} ${jkr}dot/
done
}
jkrnix_install
jkrnix_symlinks