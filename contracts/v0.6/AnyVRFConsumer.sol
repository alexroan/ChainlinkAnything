// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./TokenSwap.sol";

abstract contract AnyVRFConsumer is VRFConsumerBase {
    using TokenSwap for IUniswapV2Router02;
    
    bytes32 internal s_keyHash;
    uint256 internal s_linkFee;
    IUniswapV2Router02 internal s_uniswapRouter;
    
    /**
     * Constructor inherits VRFConsumerBase
     */
    constructor(
        address vrfCoordinator,
        address linkToken,
        bytes32 keyHash,
        uint256 linkFee,
        address uniswapRouter
    )
        VRFConsumerBase(vrfCoordinator, linkToken) public
    {
        s_keyHash = keyHash;
        s_linkFee = linkFee;
        s_uniswapRouter = IUniswapV2Router02(uniswapRouter);
    }

    function requestRandomnessWith(
        address token,
        uint256 deadline,
        uint256 seed
    )
        internal returns (bytes32)
    {
        s_uniswapRouter.swap(token, address(LINK), s_linkFee, deadline);
        return requestRandomness(s_keyHash, s_linkFee, seed);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        override internal virtual;
}
