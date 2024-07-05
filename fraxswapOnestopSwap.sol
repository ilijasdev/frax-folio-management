// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract fraxswapOnestopSwap {
    // SETTING THE FRAXSWAP ROUTER ADDRESS
    address private constant FRAXSWAP_ROUTER = 0x39cd4db6460d8B5961F73E997E86DdbB7Ca4D5F6;
    IFraxswapV1Router private fraxswapRouter = IFraxswapV1Router(FRAXSWAP_ROUTER);

    // SETTING THE WHITELISTED TOKENS
    address private constant wfrxETH = 0xFC00000000000000000000000000000000000006;
    address private constant fraxSTABLE = 0xFc00000000000000000000000000000000000001;
    address private constant dogeFXD = 0xdeBb8a79B025B2Fc2CA506F0c69497B60B91235C;

    IERC20 private wfrxeth = IERC20(wfrxETH);
    IERC20 private frax = IERC20(fraxSTABLE);

    // Implement your swap functions here. First step is to approve the contract to spend the token.
    // Then take the whitelisted tokens as input and use another input parameter that will set trader desired percentages of the tokens

    // If trader want stable portfolio, convert 80% of ETH to fraxSTABLE, 5% to dogeFXD and 15% to wfrxETH
    // If trader want bluechip portfolio, convert 50% of ETH to fraxSTABLE, 5% to dogeFXD and 45% to wfrxETH
    // If trader is degen, convert 10% of ETH to fraxSTABLE, 80% to dogeFXD and 10% to wfrxETH

    // Swap wfrxETH to fraxSTABLE
    function masterSwapper(uint256 amountIn, uint256 amountOutMin)
        external
    {
        wfrxeth.approve(address(fraxswapRouter), amountIn);
        wfrxeth.transferFrom(msg.sender, address(this), amountIn);

        address[] memory path;
        path = new address[](2);
        path[0] = wfrxETH;
        path[1] = fraxSTABLE;

        fraxswapRouter.swapExactTokensForTokens(
            amountIn, amountOutMin, path, msg.sender, block.timestamp
        );
    }
}

// INTERFACE FOR THE FRAXSWAP v2 ROUTER

interface IFraxswapV1Router {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOutWithTwamm(
        uint amountIn, 
        address[] memory path
    ) external view returns (uint[] memory amounts);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}