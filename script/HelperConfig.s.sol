// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Constants} from "./Constants.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {MockLinkToken} from "@chainlink/contracts/src/v0.8/mocks/MockLinkToken.sol";

contract HelperConfig is Script, Constants {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        uint256 subscriptionId;
        address vrfCoordinator;
        bytes32 keyHash;
        address linkToken;
        uint256 automationInterval;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public s_networkConfigs;

    constructor() {
        s_networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaNetworkConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getNetworkConfig(block.chainid);
    }

    function getSepoliaNetworkConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            subscriptionId: 106590533650702096389359900102903972821907773804702910517760447055777228601345,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            automationInterval: 30
        });
    }

    function getLocalNetworkConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.vrfCoordinator != address(0)) {
            return localNetworkConfig;
        }

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorV2_5Mock =
            new VRFCoordinatorV2_5Mock(MOCK_VRF_BASE_FEE, MOCK_VRF_GAS_PRICE, MOCK_VRF_WEI_PER_UINT);
        uint256 newSubscriptionId = vrfCoordinatorV2_5Mock.createSubscription();
        MockLinkToken linkToken = new MockLinkToken();
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            subscriptionId: newSubscriptionId,
            vrfCoordinator: address(vrfCoordinatorV2_5Mock),
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            linkToken: address(linkToken),
            automationInterval: 30
        });

        return localNetworkConfig;
    }

    function getNetworkConfig(uint256 chainId) public returns (NetworkConfig memory) {
        if (chainId == ETH_SEPOLIA_CHAIN_ID) {
            return s_networkConfigs[chainId];
        } else if (chainId == ANVIL_CHAIN_ID) {
            return getLocalNetworkConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }
}
