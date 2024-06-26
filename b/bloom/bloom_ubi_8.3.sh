# -----------------------------------------------------------------------------
#
# Package       : "bloom"
# Version       : v1.0.0
# Source repo   : "https://github.com/bits-and-blooms/bloom"
# Tested on     :ubi 8.3
# Maintainer: Priya Seth<sethp@us.ibm.com> Adilhusain Shaikh <Adilhusain.Shaikh@ibm.com>
# Script License: Apache License, Version 2 or later
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

#!/bin/bash

PACKAGE_NAME="bloom"
PACKAGE_URL="https://github.com/bits-and-blooms/bloom"
PACKAGE_VERSION=${1:-"v1.0.0"}

export GO_VERSION=${GO_VERSION:-"1.16"}
export GOROOT=${GOROOT:-"/usr/local/go"}
export GOPATH=${GOPATH:-$HOME/go}
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin:/usr/local/bin

OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)

# steps to clean up the PKG installation
if [ "$1" = "clean" ]; then
    rm -rf /usr/local/go
    rm -rf $HOME/go
    exit 0
fi

echo "installing dependencies from system repo"
dnf install -y gcc gcc-c++ wget curl-devel git -y >/dev/null

# installing golang
wget https://golang.org/dl/go$GO_VERSION.linux-ppc64le.tar.gz
tar -C /usr/local/ -xzf go$GO_VERSION.linux-ppc64le.tar.gz
rm -f go$GO_VERSION.linux-ppc64le.tar.gz

mkdir -p $GOPATH/src/github.com/bits-and-blooms

#building and testing bloom
cd $GOPATH/src/github.com/bits-and-blooms
if ! git clone $PACKAGE_URL $PACKAGE_NAME; then
    echo "------------------$PACKAGE_NAME:clone_fails---------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL |  $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Clone_Fails"
    exit 1
fi

cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION
#create go.mod if it doesn't exist
if [[ $(echo "$GO_VERSION 1.11" | awk '{print ($1 >= $2)}') == 1 ]]; then
    go mod init
    go mod edit -replace github.com/willf/bitset=github.com/bits-and-blooms/bitset@$PACKAGE_VERSION
    go mod tidy
fi

if ! go install; then
    echo "------------------$PACKAGE_NAME:install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Install_Fails"
    exit 1
fi

if ! go test -v ./...; then
    echo "------------------$PACKAGE_NAME:install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Install_success_but_test_Fails"
    exit 1
else
    echo "------------------$PACKAGE_NAME:install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi
