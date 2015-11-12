#!/bin/bash

cpi_version=${cpi_version:-16}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/..

export PATH=$PWD/bin:$PATH

bosh-init delete concourse-openstack.yml \
  assets/bosh-openstack-cpi-release-${cpi_version}.tgz
