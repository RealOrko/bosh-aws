#!/usr/bin/env bash

terraform init
terraform apply --auto-approve

IFS=
rm -rf $(pwd)/.privatekey
echo $(terraform output cloudfoundry_private_key) > .privatekey
chmod 400 $(pwd)/.privatekey
ssh-add $(pwd)/.privatekey

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

cd ./cloudfoundry-bosh-deploy

bosh create-env bosh.yml \
  --state=state.json \
  --vars-store=creds.yml \
  -o aws/cpi.yml \
  -o bosh-lite.yml \
  -o bosh-lite-runc.yml \
  -o jumpbox-user.yml \
  -o external-ip-with-registry-not-recommended.yml \
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

cd --

export BOSH_ROOT_PATH=$(pwd)
export BOSH_ENVIRONMENT=$TF_EXTERNAL_IP
export BOSH_CA_CERT="$(bosh int $BOSH_ROOT_PATH/cloudfoundry-bosh-deploy/creds.yml --path /director_ssl/ca)"
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="$(bosh int $BOSH_ROOT_PATH/cloudfoundry-bosh-deploy/creds.yml --path /admin_password)"
export BOSH_GW_HOST=$BOSH_ENVIRONMENT
export BOSH_GW_USER=vcap
export BOSH_GW_PRIVATE_KEY=$TF_PRIVATE_KEY_PATH

bosh env
