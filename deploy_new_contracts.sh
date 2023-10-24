#!/bin/bash

set -e

echo "Cleaning the build directory..."
rm -rf build

echo "Compiling and deploying the contracts..."
truffle migrate --network ganache

echo "Uploading the new contract ABIs to Google Drive..."
python3 upload_new_contract_abis.py


