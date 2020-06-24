#!/usr/bin/env bash
cd $(dirname "$0")
for dist in appletvos-arm64/1300 iphoneos-arm64/1{5,6}00 watchos-arm64/1400 watchos-arm/1400; do
    if [[ "${dist}" == "iphoneos-arm"* ]]; then
        arch=iphoneos-arm
    elif [[ "${dist}" == "watchos-arm"* ]]; then
        arch=watchos-arm
    else
        arch=$(echo "${dist}" | cut -f1 -d '/')
    fi
    binary=binary-${arch}
    mkdir -p dists/${dist}/main/${binary}
    rm -f dists/${dist}/{Release{,.gpg},main/${binary}/{Packages{,.xz,.zst},Release{,.gpg}}}
    cp -a CydiaIcon*.png dists/${dist}

    ./apt-ftparchive packages pool/main/${dist} > \
                dists/${dist}/main/${binary}/Packages 2>/dev/null
    xz -c9 dists/${dist}/main/${binary}/Packages > dists/${dist}/main/${binary}/Packages.xz
    zstd -q -c19 dists/${dist}/main/${binary}/Packages > dists/${dist}/main/${binary}/Packages.zst
    
    ./apt-ftparchive release -c config/${arch}-basic.conf dists/${dist}/main/${binary} > dists/${dist}/main/${binary}/Release 2>/dev/null
    ./apt-ftparchive release -c config/$(echo "${dist}" | cut -f1 -d '/').conf dists/${dist} > dists/${dist}/Release 2>/dev/null 

    gpg -abs -u C59F3798A305ADD7E7E6C7256430292CF9551B0E -o dists/${dist}/Release.gpg dists/${dist}/Release
done
