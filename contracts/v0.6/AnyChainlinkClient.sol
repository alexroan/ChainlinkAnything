// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./TokenSwap.sol";

abstract contract AnyChainlinkClient is ChainlinkClient {
    using TokenSwap for IUniswapV2Router02;

    address immutable LINK_TOKEN;

    address internal s_oracle;
    bytes32 internal s_jobId;
    uint256 internal s_linkFee;
    IUniswapV2Router02 internal s_uniswapRouter;

    constructor(
        address linkAddress,
        address oracleAddress,
        bytes32 jobId,
        uint256 fee,
        address uniswapRouter
    ) public {
        LINK_TOKEN = linkAddress;
        setChainlinkToken(linkAddress);
        s_oracle = oracleAddress;
        s_jobId = jobId;
        s_linkFee = fee;
        s_uniswapRouter = IUniswapV2Router02(uniswapRouter);
    }

    function sendChainlinkRequestWith(
        address token,
        uint256 deadline,
        Chainlink.Request memory request
    ) 
        internal returns (bytes32) 
    {
        s_uniswapRouter.swap(token, address(LINK_TOKEN), s_linkFee, deadline);
        return sendChainlinkRequestTo(s_oracle, request, s_linkFee);
    }
}