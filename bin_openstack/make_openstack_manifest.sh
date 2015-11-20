#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/..

if [[
"${EIP}X" == "X" ||
"${PRIVATE_KEY_PATH}X" == "X" 
]]; then
  echo "USAGE: EIP=xxx PRIVATE_KEY_PATH=xxx ./bin/make_manifest.sh"
  exit 1
fi

POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-"secret-postgres-password"}

cat >concourse-openstack.yml <<YAML
---
name: concourse

resource_pools:
- name: default
  network: default
  stemcell:
    url: https://bosh.io/d/stemcells/bosh-openstack-kvm-ubuntu-trusty-go_agent?v=2830
    sha1: 1abc023e8ccf9a38516587ed552ccc2d636dd616
  cloud_properties:
    instance_type: m1.xlarge

jobs:
- name: concourse
  instances: 1
  persistent_disk: 10240
  templates:
  - {release: concourse, name: atc}
  - {release: concourse, name: tsa}
  - {release: concourse, name: groundcrew}
  - {release: concourse, name: postgresql}
  - {release: garden-linux, name: garden}
  networks:
  - name: vip
    static_ips: [$EIP]
    default: [dns, gateway]
  - name: default

  properties:
    atc:
      development_mode: true

      postgresql:
        address: 127.0.0.1:5432
        role:
          name: atc
          password: ${POSTGRES_PASSWORD}

    postgresql:
      databases: [{name: atc}]
      roles:
        - role:
          name: atc
          password: ${POSTGRES_PASSWORD}

    tsa:
      forward_host: $EIP
      atc:
        address: 127.0.0.1:8080

    groundcrew:
      tsa:
        host: 127.0.0.1

    garden:
      listen_network: tcp
      listen_address: 0.0.0.0:7777

      allow_host_access: true

networks:
- name: default
  type: dynamic
  cloud_properties:
    net_id: $OS_NET_ID

cloud_provider:
  template: {name: openstack_cpi, release: bosh-openstack-cpi}

  ssh_tunnel:
    host: $EIP
    port: 22
    user: vcap
    private_key: $PRIVATE_KEY_PATH

  registry: &registry
    username: admin
    password: admin
    port: 6901
    host: localhost

  # Tells bosh-micro how to contact remote agent
  mbus: https://nats:nats@$EIP:6868

  properties:
    openstack: 
      auth_url: $OS_AUTH_URL
      username: $OS_USERNAME
      api_key: $OS_PASSWORD
      tenant: $OS_TENANT_ID
      region: $OS_REGION_NAME
      default_security_groups: ["concourse"] # CHANGE
      default_key_name: concourse

    # Tells CPI how agent should listen for requests
    agent: {mbus: "https://nats:nats@0.0.0.0:6868"}

    registry: *registry

    blobstore:
      provider: local
      path: /var/vcap/micro_bosh/data/cache

    ntp:
      - 0.pool.ntp.org
      - 1.pool.ntp.org
      - 2.pool.ntp.org
      - 3.pool.ntp.org
YAML
