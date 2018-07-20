#!/bin/bash
#
# Maintainer script for publishing releases.

set -e

source=$(dpkg-parsechangelog -S Source)
version=$(dpkg-parsechangelog -S Version)
distribution=$(dpkg-parsechangelog -S Distribution)
codename=$(debian-distro-info --codename --${distribution})

OS=debian DIST=${codename} ARCH=armhf pbuilder-ev3dev build
debsign ~/pbuilder-ev3dev/debian/${codename}-armhf/${source}_${version}_armhf.changes
dput ev3dev-debian ~/pbuilder-ev3dev/debian/${codename}-armhf/${source}_${version}_armhf.changes

ssh ev3dev@reprepro.ev3dev.org "reprepro -b ~/reprepro/raspbian includedsc ${codename} \
    ~/reprepro/debian/pool/main/${source:0:1}/${source}/${source}_${version}.dsc"
ssh ev3dev@reprepro.ev3dev.org "reprepro -b ~/reprepro/raspbian includedeb ${codename} \
    ~/reprepro/debian/pool/main/${source:0:1}/${source}/ev3dev-connman-config_${version}_all.deb"

gbp buildpackage --git-tag-only
