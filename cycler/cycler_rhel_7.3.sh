# ----------------------------------------------------------------------------
#
# Package       : cycler
# Version       : 0.10.0
# Source repo   : https://github.com/matplotlib/cycler
# Tested on     : rhel_7.3
# Script License: Apache License, Version 2 or later
# Maintainer    : Archa Bhandare <barcha@us.ibm.com>
#
# Disclaimer: This script has been tested in non-root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

## Update source
sudo yum update -y

## Install dependencies
sudo yum install -y git wget deltarpm libgdal-dev libproj-dev gdal-bin build-essential python-setuptools

## Clone repo
git clone https://github.com/matplotlib/cycler

## Build, Install and Test
cd cycler/
sudo python setup.py install && sudo python setup.py test
