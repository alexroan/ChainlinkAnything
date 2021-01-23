// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "../../v0.6/AnyVRFConsumer.sol";

contract KovanDaiTokenVRF is AnyVRFConsumer {
    address constant public daiAddress = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
    uint256 public randomResult;

    constructor() AnyVRFConsumer(
        0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9,
        0xa36085F69e2889c224210F603D836748e7dC0088,
        0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4,
        0.1 * 10 ** 18,
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    ) public {}

    function getRandomNumber() public returns (bytes32) {
        uint deadline = block.timestamp + 15;
        return requestRandomnessWith(daiAddress, deadline, 1);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }
}
