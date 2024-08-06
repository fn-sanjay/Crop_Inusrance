# Crop Insurance Smart Contract

This repository contains the Solidity smart contract code for a decentralized crop insurance application. The project is currently under development, and testing is ongoing.

## Overview

The Crop Insurance smart contract aims to provide automated insurance claims for farmers based on weather conditions. The contract uses Chainlink Functions to fetch real-time weather data and determine if a claim should be paid out based on predefined conditions.

## Features

- Farmers can create insurance policies by specifying coverage amounts and locations.
- The contract interacts with Chainlink Functions to fetch weather data.
- Automated claim processing based on weather conditions such as heavy rainfall.
- Secure and decentralized insurance management.

## Current Status

- Contract Development: Completed
- Testing: Pending

## Setup Instructions

### Prerequisites

- [Foundry](https://github.com/foundry-rs/foundry): A blazing fast, portable and modular toolkit for Ethereum application development.
- [Anvil](https://book.getfoundry.sh/anvil/): A local Ethereum node designed for development.

### Installation

1. **Install Foundry**

   Follow the installation instructions for Foundry from the official [Foundry GitHub page](https://github.com/foundry-rs/foundry).

2. **Install Dependencies**

   Ensure you have the necessary dependencies installed by running:

   ```bash
   forge install
3. **Start Anvil**
   Start the Anvil node with the following command:

   ```bash
   anvil
4. **Compiling Contracts**
   Compile the smart contracts using Foundry:

   ```bash
   forge build
5. **Run Deployment Script**
   Deploy the smart contract to the local Anvil node:

   ```bash
   forge script script/deploy.s.sol --rpc-url http://localhost:8545 --private-key <your-private-key>
## Project Structure
 - src/: Contains the Solidity smart contracts.
 - script/: Contains the deployment scripts.
 - lib/: Dependencies and libraries.
 - test/: Contains test scripts (to be added).

## Contributing
 Contributions are welcome! Please fork the repository and create a pull request with your changes. Make sure to include tests for any new features or bug fixes.

## License
 This project is licensed under the MIT License. See the LICENSE file for details.

## Contact
 For any questions or support, please open an issue in the repository.









  