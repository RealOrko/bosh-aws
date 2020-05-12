#!/usr/bin/env bash

source <(sed -E -n 's/[^#]+/export &/ p' ~/.environment)

export | grep TF_
export BOSH_ENVIRONMENT=$TF_EXTERNAL_IP

git clone https://github.com/cloudfoundry/cf-deployment ~/workspace/cf-deployment
cd ~/workspace/cf-deployment

bosh update-cloud-config ~/workspace/cf-deployment/iaas-support/bosh-lite/cloud-config.yml

export STEMCELL_VERSION=$(bosh int cf-deployment.yml --path '/stemcells/alias=default/version')
bosh upload-stemcell "https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-xenial-go_agent?v=$STEMCELL_VERSION"
bosh stemcells

export SYSTEM_DOMAIN=$BOSH_ENVIRONMENT.sslip.io
bosh -d cf deploy ~/workspace/cf-deployment/cf-deployment.yml \
    -o ~/workspace/cf-deployment/operations/bosh-lite.yml \
    -o ~/workspace/cf-deployment/operations/use-compiled-releases.yml \
    --vars-store deployment-vars.yml \
    -v system_domain=$SYSTEM_DOMAIN

bosh deployments
