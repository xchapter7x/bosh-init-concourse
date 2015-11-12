#!/bin/bash

# concourse_version=${concourse_version:-0.45.0}
concourse_version=${concourse_version:-0.45.0+dev.1}
garden_version=${garden_version:-0.190.0}
cpi_version=${cpi_version:-16}
stemcell_version=${stemcell_version:-2830}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/..

export PATH=$PWD/bin:$PATH

bosh-init deploy concourse-openstack.yml \
  assets/bosh-stemcell-${stemcell_version}-openstack-kvm-ubuntu-trusty-go_agent.tgz \
  assets/bosh-openstack-cpi-release-${cpi_version}.tgz \
  assets/concourse-${concourse_version}.tgz \
  assets/garden-linux-release-${garden_version}.tgz
