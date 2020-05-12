#!/usr/bin/env bash

ssh-add -D $(pwd)/.privatekey
rm -rf $(pwd)/.privatekey
# source <(sed -E -n 's/[^#]+/export &/ p' .environment)

# cd ./cloudfoundry-bosh-deploy

#bosh delete-env ~/workspace/bosh-deployment/bosh.yml \
#  --state state.json \
#  --vars-store ./creds.yml \
#  -o aws/cpi.yml \
#  -o bosh-lite.yml \
#  -o bosh-lite-runc.yml \
#  -o jumpbox-user.yml \
#  -o external-ip-with-registry-not-recommended.yml \
#  -v director_name=$TF_DIRECTOR_NAME \
#  -v internal_cidr=$TF_INTERNAL_CIDR \
#  -v internal_gw=$TF_INTERNAL_GW \
#  -v internal_ip=$TF_INTERNAL_IP \
#  -v access_key_id=$AWS_ACCESS_KEY_ID \
#  -v secret_access_key=$AWS_SECRET_ACCESS_KEY \
#  -v region=$AWS_DEFAULT_REGION \
#  -v az=$TF_AVAILABILITY_ZONE \
#  -v default_key_name=$TF_DEFAULT_KEY_NAME \
#  -v default_security_groups=[$TF_SECURITY_GROUP] \
#  --var-file private_key=$TF_PRIVATE_KEY_PATH \
#  -v subnet_id=$TF_SUBNET_ID \
#  -v external_ip=$TF_EXTERNAL_IP

#cd --

terraform destroy --auto-approve
