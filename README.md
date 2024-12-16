# Rock Paper Scissors Smart Contracts

This project contains smart contracts for a Rock Paper Scissors game, along with deployment scripts and tests.

## Contracts

- `RPSContract.sol`: The main contract for the Rock Paper Scissors game.
- `RPSContractFactory.sol`: A factory contract for deploying new instances of `RPSContract`.
- `contracts/RPSContractV2.sol`: A newer version of the Rock Paper Scissors contract.

## Scripts

- `deploy_new_contracts.sh`: A shell script for deploying the contracts.
- `migrations/1_deploy_contracts.js`: A javascript file for deploying the contracts using truffle.
- `upload_new_contract_abis.py`: A python script for uploading contract ABIs.

## Testing

- Tests are located in the `test` directory.

## Setup

1. Install dependencies:
   ```bash
   npm install
   pip install -r requirements.txt
   ```

2. Configure truffle:
   - Update `truffle-config.js` with your network settings.

3. Deploy contracts:
   ```bash
   truffle migrate
   ```

## Usage

- Use the deployed contracts to play Rock Paper Scissors.
- See the test files for examples of how to interact with the contracts.

## Contributing

- Contributions are welcome! Please submit a pull request.
