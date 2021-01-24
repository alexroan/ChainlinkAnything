// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IERC20.sol";

library TokenSwap {

    function swap(
        IUniswapV2Router02 uniswapRouter,
        address from,
        address to,
        uint256 toAmount,
        uint256 deadline
    ) internal {
        address[] memory path = getTokensPath(from, to);
        IERC20 erc20 = IERC20(from);
        uint256 tokenAmountIn = uniswapRouter.getAmountsIn(toAmount, path)[0];
        uint256 tokenBalance = erc20.balanceOf(address(this));
        require(tokenBalance >= tokenAmountIn, "Not enough chosen token");
        require(
            erc20.approve(address(uniswapRouter), tokenBalance),
            "Could not approve"
        );
        uint256[] memory amounts = uniswapRouter.swapTokensForExactTokens(
            toAmount,
            tokenBalance,
            path,
            address(this),
            deadline
        );
        require(amounts[1] >= toAmount, "Not enough output from swap");
    }

    function getTokensPath(address from, address to) private pure returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = from;
        path[1] = to;
        return path;
    }
}