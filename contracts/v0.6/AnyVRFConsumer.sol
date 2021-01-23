// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
import "@uniswap/v2-core/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

abstract contract RandomNumberConsumer is VRFConsumerBase {
    
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

    function requestRandomnessWith(address token, uint256 deadline, uint256 seed) internal returns (bytes32 requestId) {
        address[] memory path = getTokenToLinkPath(token);
        IERC20 erc20 = IERC20(token);
        uint256 tokenAmountIn = s_uniswapRouter.getAmountsIn(s_linkFee, path)[0];
        uint256 tokenBalance = erc20.balanceOf(address(this));
        require(tokenBalance >= tokenAmountIn, "Not enough chosen token");
        require(
            erc20.approve(address(s_uniswapRouter), tokenBalance),
            "Could not approve"
        );
        uint256[] memory amounts = s_uniswapRouter.swapTokensForExactTokens(
            s_linkFee,
            tokenBalance,
            path,
            address(this),
            deadline
        );
        require(amounts[1] >= s_linkFee, "Not enough LINK from swap");
        return requestRandomness(s_keyHash, s_linkFee, seed);
    }

    function getTokenToLinkPath(address token) internal view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = address(LINK);
        return path;
    }
}
