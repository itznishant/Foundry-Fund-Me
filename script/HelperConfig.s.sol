// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";
import {Script} from "forge-std/Script.sol";

// 1. Deploy Mocks when on a local anvil chain

// 2. Keep track of pricefeed contracts for different chains
// Sepolia: ETH/USD
// Mainnet: ETH/USD

contract HelperConfig is Script {
	NetworkConfig public activeNetworkConfig;

	uint8 public constant DECIMALS = 8;
	int256 public constant INITIAL_PRICE = 2000e8;

	struct NetworkConfig {
		address priceFeed; // ETH/USD price feed address
	}

	constructor() {
		if(block.chainid == 11155111) {
			activeNetworkConfig = getSepoliaETHConfig();
		} else if(block.chainid == 1) {
			activeNetworkConfig = getMainnetETHConfig();
		} else {
			activeNetworkConfig = getOrCreateAnvilETHConfig();
		}
	}

	function getSepoliaETHConfig() public pure returns(NetworkConfig memory) {
		// price feed address
		NetworkConfig memory sepoliaConfig = NetworkConfig({
			priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
		});
		return sepoliaConfig;
	}

	function getMainnetETHConfig() public pure returns(NetworkConfig memory) {
		NetworkConfig memory mainnetConfig = NetworkConfig({
			priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 //MAINNET PRICE FEED ADDRESS
		});
		return mainnetConfig;
	}

	function getOrCreateAnvilETHConfig() public returns(NetworkConfig memory) {

		if(activeNetworkConfig.priceFeed != address(0)) {
			return activeNetworkConfig;
		}

		// price feed address
		// 1. Deploy Mock 
		// 2. Return Mock address
		vm.startBroadcast();

		MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
			DECIMALS,
			INITIAL_PRICE);

		vm.stopBroadcast();

		NetworkConfig memory anvilConfig = NetworkConfig({
			priceFeed: address(mockPriceFeed)
		});
		return anvilConfig;
	}
}