// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import {Script} from "forge-std/Script.sol";
// import "../src/Staking.sol";
// import "../src/tokens/Bead.sol";

// contract DeployScript is Script {
//     function run() external {
//         uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
//         vm.startBroadcast(deployerPrivateKey);

//         Bead token = new Bead();

//         // StakingPoolFactory factory = new StakingPoolFactory();

//         vm.stopBroadcast();
//     }
// }