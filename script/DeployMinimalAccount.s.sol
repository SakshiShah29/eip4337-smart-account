//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";

contract DeployMinimalAccount is Script {
    function run() external {}

    function deployMinimalAccount()
        public
        returns (HelperConfig, MinimalAccount)
    {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig
            .getConfigByChainId(block.chainid);
        vm.startBroadcast(networkConfig.account);
        MinimalAccount minimalAccount = new MinimalAccount(
            networkConfig.account,
            networkConfig.entryPoint
        );
        vm.stopBroadcast();
        return (helperConfig, minimalAccount);
    }
}
