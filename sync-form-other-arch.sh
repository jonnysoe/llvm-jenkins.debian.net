#!/bin/bash
set -e

if test $# -ne 3; then
    echo "error"
    echo "syntax $0 DISTRO HOST ARCH"
    exit 1
fi

DISTRO=$1
HOST=$2
ARCH=$3
rsync -avzh --delete jenkins@$HOST:/srv/repository/$DISTRO/ /tmp/tmp-$DISTRO/
if ! test -d /tmp/tmp-$DISTRO/pool/main/; then
        echo "Distro $DISTRO not existing yet"
        exit 0
fi

for f in /tmp/tmp-$DISTRO/dists/llvm-*/main/binary-$ARCH/; do
    echo $f
    VERSION=$(echo $f|sed -e "s|/tmp/tmp-$DISTRO/dists/llvm-toolchain-$DISTRO-\([[:digit:]]\+\)/.*|\1|g")
    echo "VERSION $VERSION"
    re='^[0-9]+$'
    if ! [[ $VERSION =~ $re ]] ; then
            # maybe debian unstable
            VERSION=$(echo $f|sed -e "s|/tmp/tmp-$DISTRO/dists/llvm-toolchain-\([[:digit:]]\+\)/.*|\1|g")
            if ! [[ $VERSION =~ $re ]] ; then
                echo "Probably the nightly version"
                break
            fi
    fi
    # Workaround: don't import libclc (provided by amd64)
    # checksum differences otherwise
    rm -f /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain*/libclc-*deb

    # Second workaround to remove _all packages
    rm -f /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain*/*_all.deb

    # Import of the stable and stabilisation version
    if test $DISTRO == "unstable"; then
        reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$VERSION /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-$VERSION/*deb
    else
	echo reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$DISTRO-$VERSION /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-$VERSION/*deb
        reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$DISTRO-$VERSION /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-$VERSION/*deb
    fi
done

# Import of the nightly builds

if test -d /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain/ -o -d /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-snapshot/; then
    if test $DISTRO == "unstable"; then
        reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-snapshot/*deb
    else
        reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$DISTRO /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-snapshot/*deb
    fi
fi
