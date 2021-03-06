#!/bin/bash

# concourse_version=${concourse_version:-0.45.0}
concourse_version=${concourse_version:-"0.45.0+dev.1"}
garden_version=${garden_version:-0.190.0}
cpi_version=${cpi_version:-16}
stemcell_version=${stemcell_version:-2830}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd $DIR/..
mkdir -p assets
mkdir -p bin

if [[ ! -f assets/concourse-${concourse_version}.tgz ]]; then
  echo "Downloading concourse-${concourse_version}.tgz"
  if [[ "${concourse_version}" == "0.45.0+dev.1" ]]; then
    curl -Lo assets/concourse-${concourse_version}.tgz \
      "https://s3.amazonaws.com/concourse-tutorial-bosh-init/concourse-0.45.0%20dev.1.tgz"
  else
    curl -Lo assets/concourse-${concourse_version}.tgz \
      "https://bosh.io/d/github.com/concourse/concourse?v=${concourse_version}"
  fi
fi
if [[ ! -f assets/garden-linux-release-${garden_version}.tgz ]]; then
  echo "Downloading garden-linux-release-${garden_version}.tgz"
  curl -Lo assets/garden-linux-release-${garden_version}.tgz \
    "https://bosh.io/d/github.com/cloudfoundry-incubator/garden-linux-release?v=${garden_version}"
fi
if [[ ! -f assets/bosh-openstack-cpi-release-${cpi_version}.tgz ]]; then
  echo "Downloading bosh-openstack-cpi-release-${cpi_version}.tgz"
  curl -Lo assets/bosh-openstack-cpi-release-${cpi_version}.tgz \
    "http://bosh.io/d/github.com/cloudfoundry-incubator/bosh-openstack-cpi-release?v=${cpi_version}"
fi
if [[ ! -f assets/bosh-stemcell-${stemcell_version}-openstack-kvm-ubuntu-trusty-go_agent.tgz ]]; then
  echo "Downloading bosh-stemcell-${stemcell_version}-openstack-kvm-ubuntu-trusty-go_agent.tgz"
  curl -Lo assets/bosh-stemcell-${stemcell_version}-openstack-kvm-ubuntu-trusty-go_agent.tgz \
    https://d26ekeud912fhb.cloudfront.net/bosh-stemcell/openstack/bosh-stemcell-${stemcell_version}-openstack-kvm-ubuntu-trusty-go_agent.tgz
fi
if [[ ! -f bin/bosh-init ]]; then
  if [[ ! -f $DIR/../bin/bosh-init ]]; then
    echo "Downloading bosh-init"
    os_name=$(uname -s)
    if [ "$os_name" == "Linux" ]; then
      curl -Lo bin/bosh-init https://s3.amazonaws.com/concourse-tutorial-bosh-init/bosh-init-linux64
    else
      curl -Lo bin/bosh-init https://s3.amazonaws.com/concourse-tutorial-bosh-init/bosh-init-darwin
    fi
    chmod +x bin/bosh-init
  fi
fi
