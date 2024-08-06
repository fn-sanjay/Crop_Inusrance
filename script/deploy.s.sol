// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/insurance.sol";

contract Deploy is Script {
    function run() external {
        // Define the constructor arguments
        address router = address(0x123);
        bytes32 donId = 0; 
        uint64 subscriptionId = 1; 
        uint32 gasLimit = 100000; 

        vm.startBroadcast();
        CropInsurance insurance = new CropInsurance(router, donId, subscriptionId, gasLimit);

        

        vm.stopBroadcast(); 

        
        console.log("CropInsurance deployed to:", address(insurance));
    }
}
