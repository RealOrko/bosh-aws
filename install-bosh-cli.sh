#!/usr/bin/env bash

rm -rf $(pwd)/assets
mkdir -p $(pwd)/assets

curl -s https://api.github.com/repos/cloudfoundry/bosh-cli/releases/latest \
| grep "browser_download_url.*linux-amd64" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -P $(pwd)/assets/ -qi -

mv $(pwd)/assets/bosh-cli-* $(pwd)/assets/bosh
chmod +x $(pwd)/assets/bosh
sudo rm -rf /usr/local/bin/bosh
sudo cp $(pwd)/assets/bosh /usr/local/bin

bosh --version
