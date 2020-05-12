#!/usr/bin/env bash

terraform init
terraform apply --auto-approve

rm -rf $(pwd)/cloudfoundry-bosh-deploy
git clone https://github.com/cloudfoundry/bosh-deployment.git $(pwd)/cloudfoundry-bosh-deploy

IFS=
rm -rf $(pwd)/.privatekey
echo $(terraform output cloudfoundry_private_key) > .privatekey
chmod 400 $(pwd)/.privatekey
ssh-add $(pwd)/.privatekey

export BOSH_ROOT_DIRECTORY=$(pwd)/cloudfoundry-bosh-deploy
export TF_DIRECTOR_NAME="cloudfoundry-bosh-director"
export TF_EXTERNAL_IP=$(terraform output cloudfoundry_elastic_ip_public_ip) 
export TF_INTERNAL_IP=$(terraform output cloudfoundry_elastic_ip_private_ip) 
export TF_INTERNAL_CIDR=$(terraform output cloudfoundry_vpc_subnet_cidr_block)
export TF_SUBNET_ID=$(terraform output cloudfoundry_vpc_subnet_id)
export TF_AVAILABILITY_ZONE=$(terraform output cloudfoundry_availability_zone)
export TF_SECURITY_GROUP=$(terraform output cloudfoundry_security_group_name)
export TF_DEFAULT_KEY_NAME=$(terraform output cloudfoundry_keyname)
export TF_PRIVATE_KEY_PATH=$(pwd)/.privatekey
export TF_INTERNAL_GW=10.0.0.1

rm -rf $(pwd)/.environment
echo BOSH_ROOT_DIRECTORY=$BOSH_ROOT_DIRECTORY >> $(pwd)/.environment
echo TF_DIRECTOR_NAME=$TF_DIRECTOR_NAME >> $(pwd)/.environment
echo TF_EXTERNAL_IP=$TF_EXTERNAL_IP >> $(pwd)/.environment
echo TF_INTERNAL_IP=$TF_INTERNAL_IP >> $(pwd)/.environment
echo TF_INTERNAL_CIDR=$TF_INTERNAL_CIDR >> $(pwd)/.environment
echo TF_INTERNAL_GW=$TF_INTERNAL_GW >> $(pwd)/.environment
echo TF_SUBNET_ID=$TF_SUBNET_ID >> $(pwd)/.environment
echo TF_AVAILABILITY_ZONE=$TF_AVAILABILITY_ZONE >> $(pwd)/.environment
echo TF_SECURITY_GROUP=$TF_SECURITY_GROUP >> $(pwd)/.environment
echo TF_DEFAULT_KEY_NAME=$TF_DEFAULT_KEY_NAME >> $(pwd)/.environment
echo TF_PRIVATE_KEY_PATH=$TF_PRIVATE_KEY_PATH >> $(pwd)/.environment

bosh create-env $(pwd)/bosh.yml \
  --state=$BOSH_ROOT_DIRECTORY/state.json \
  --vars-store=$BOSH_ROOT_DIRECTORY/creds.yml \
  -o $BOSH_ROOT_DIRECTORY/aws/cpi.yml \
  -o $BOSH_ROOT_DIRECTORY/bosh-lite.yml \
  -o $BOSH_ROOT_DIRECTORY/bosh-lite-runc.yml \
  -o $BOSH_ROOT_DIRECTORY/jumpbox-user.yml \
  -o $BOSH_ROOT_DIRECTORY/external-ip-with-registry-not-recommended.yml \
  -v director_name=$TF_DIRECTOR_NAME \
  -v internal_cidr=$TF_INTERNAL_CIDR \
  -v internal_gw=$TF_INTERNAL_GW \
  -v internal_ip=$TF_INTERNAL_IP \
  -v access_key_id=$AWS_ACCESS_KEY_ID \
  -v secret_access_key=$AWS_SECRET_ACCESS_KEY \
  -v region=$AWS_DEFAULT_REGION \
  -v az=$TF_AVAILABILITY_ZONE \
  -v default_key_name=$TF_DEFAULT_KEY_NAME \
  -v default_security_groups=[$TF_SECURITY_GROUP] \
  --var-file private_key=$TF_PRIVATE_KEY_PATH \
  -v subnet_id=$TF_SUBNET_ID \
  -v external_ip=$TF_EXTERNAL_IP

export BOSH_ENVIRONMENT=$TF_EXTERNAL_IP
export BOSH_CA_CERT="$(bosh int $BOSH_ROOT_DIRECTORY/creds.yml --path /director_ssl/ca)"
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="$(bosh int $BOSH_ROOT_DIRECTORY/creds.yml --path /admin_password)"
export BOSH_GW_HOST=$BOSH_ENVIRONMENT
export BOSH_GW_USER=vcap
export BOSH_GW_PRIVATE_KEY=$TF_PRIVATE_KEY_PATH

bosh env

scp -o "StrictHostKeyChecking no" -i $TF_PRIVATE_KEY_PATH $(pwd)/.environment vcap@$BOSH_GW_HOST:~/
scp -o "StrictHostKeyChecking no" -i $TF_PRIVATE_KEY_PATH $(pwd)/install-cf.sh vcap@$BOSH_GW_HOST:~/
#ssh -o "StrictHostKeyChecking no" -i $TF_PRIVATE_KEY_PATH vcap@$BOSH_GW_HOST '~/install-cf.sh'
