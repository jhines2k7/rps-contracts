#!/bin/bash

set -e

# get network as the first command line argument
network=$1

echo "Cleaning the build directory..."
rm -rf build

echo "Compiling and deploying the contracts to the $network network..."
truffle migrate --network $network

echo "Uploading the new contract ABIs to Google Drive..."
python3 upload_new_contract_abis.py
