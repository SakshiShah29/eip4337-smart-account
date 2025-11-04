//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console2} from "forge-std/Script.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";
contract HelperConfig is Script {
    error HelperConfig_InvalidChainId();

    struct NetworkConfig {
        address entryPoint;
        address account;
    }

    uint256 constant ETH_SEPOLIA_CHAINID = 11155111;
    uint256 constant ZKSYNC_SEPOLIA_CHAINID = 300;
    uint256 constant ANVIL_ETH_CHAINID = 31337;
    address constant BURNER_WALLET = 0xf6aC8a8715024fE9Ff592D6A3f186E2B502B356a;
    // address constant FOUNDRY_DEFAULT_WALLET =
    //     0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    address constant ANVIL_DEFAULT_ACCOUNT =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    NetworkConfig public activeNetworkConfig;

    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAINID] = getEthSepoliaConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(
        uint256 chainId
    ) public returns (NetworkConfig memory) {
        if (chainId == ANVIL_ETH_CHAINID) {
            return getOrCreateAnvilEthConfig();
        } else if (networkConfigs[chainId].account != address(0)) {
            return networkConfigs[chainId];
        } else {
            revert HelperConfig_InvalidChainId();
        }
    }

    function getEthSepoliaConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789,
                account: BURNER_WALLET
            });
    }

    function getZkSyncSepoliaConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        return NetworkConfig({entryPoint: address(0), account: BURNER_WALLET});
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.account != address(0)) {
            return activeNetworkConfig;
        }
        console2.log("Deploying mocks...");
        vm.startBroadcast(ANVIL_DEFAULT_ACCOUNT);
        EntryPoint entryPoint = new EntryPoint();
        vm.stopBroadcast();

        activeNetworkConfig = NetworkConfig({
            entryPoint: address(entryPoint),
            account: ANVIL_DEFAULT_ACCOUNT
        });
        return activeNetworkConfig;
    }
    function run() external {}
}
