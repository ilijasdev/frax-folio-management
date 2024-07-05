// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract fraxswapOnestopSwapAllIn {
    // SETTING THE FRAXSWAP ROUTER ADDRESS
    address private constant FRAXSWAP_ROUTER = 0x39cd4db6460d8B5961F73E997E86DdbB7Ca4D5F6;
    IFraxswapV1Router private fraxswapRouter = IFraxswapV1Router(FRAXSWAP_ROUTER);

    // SETTING THE WHITELISTED TOKENS
    address private constant wfrxETH = 0xFC00000000000000000000000000000000000006;
    address private constant fraxSTABLE = 0xFc00000000000000000000000000000000000001;
    address private constant dogeFXD = 0xdeBb8a79B025B2Fc2CA506F0c69497B60B91235C;

    IERC20 private wfrxeth = IERC20(wfrxETH);
    IERC20 private frax = IERC20(fraxSTABLE);
    IERC20 private doge = IERC20(dogeFXD);

    // Implement your swap functions here. First step is to approve the contract to spend the token.
    // Then take the whitelisted tokens as input and use another input parameter that will set trader desired percentages of the tokens

    // If trader want stable portfolio, convert 80% of ETH to fraxSTABLE, 5% to dogeFXD and 15% to wfrxETH
    // If trader want bluechip portfolio, convert 50% of ETH to fraxSTABLE, 5% to dogeFXD and 45% to wfrxETH
    // If trader is degen, convert 10% of ETH to fraxSTABLE, 80% to dogeFXD and 10% to wfrxETH

    // Swap wfrxETH to fraxSTABLE
    function masterSwapper(
        uint256 amountInDoge, 
        uint256 amountOutMinDoge, 
        uint256 amountInFRAX, 
        uint256 amountOutMinFRAX,
        uint256 amountInWFRXETHforFXD,
        uint256 amountOutMinWFRXETHforFXD,
        uint256 amountInWFRXETHforFRAX,
        uint256 amountOutMinWFRXETHforFRAX
    )
        external
    {
        // Swapping all Doge to wfrxETH if amountInDoge and amountOutMinDoge is greater than 0
        if (amountInDoge > 0 && amountOutMinDoge > 0) {
            doge.approve(address(fraxswapRouter), amountInDoge);
            doge.transferFrom(msg.sender, address(this), amountInDoge);

            address[] memory path1;
            path1 = new address[](2);
            path1[0] = dogeFXD;
            path1[1] = wfrxETH;

            fraxswapRouter.swapExactTokensForTokens(
                amountInDoge, amountOutMinDoge, path1, msg.sender, block.timestamp
            );

            // Transfer any remaining tokens back to the caller
            doge.transfer(msg.sender, doge.balanceOf(address(this)));
        }

        // Swapping all FRAX to wfrxETH if amountInFRAX and amountOutMinFRAX is greater than 0
        if (amountInFRAX > 0 && amountOutMinFRAX > 0) {
            frax.approve(address(fraxswapRouter), amountInFRAX);
            frax.transferFrom(msg.sender, address(this), amountInFRAX);

            address[] memory path2;
            path2 = new address[](2);
            path2[0] = fraxSTABLE;
            path2[1] = wfrxETH;

            fraxswapRouter.swapExactTokensForTokens(
                amountInFRAX, amountOutMinFRAX, path2, msg.sender, block.timestamp
            );

            // Transfer any remaining tokens back to the caller
            frax.transfer(msg.sender, frax.balanceOf(address(this)));
        }

        // Check other four parameters where part of the wfrxETH will be swapped back to FXD and FRAX
        // First wfrxETH to FXD but approve and transfer twice as the amount
        wfrxeth.approve(address(fraxswapRouter), amountInWFRXETHforFXD);
        wfrxeth.transferFrom(msg.sender, address(this), amountInWFRXETHforFXD);

        address[] memory path3;
        path3 = new address[](2);
        path3[0] = wfrxETH;
        path3[1] = dogeFXD;

        fraxswapRouter.swapExactTokensForTokens(
            amountInWFRXETHforFXD, amountOutMinWFRXETHforFXD, path3, msg.sender, block.timestamp
        );

        // Second wfrxETH to FRAX
        wfrxeth.approve(address(fraxswapRouter), amountInWFRXETHforFRAX);
        wfrxeth.transferFrom(msg.sender, address(this), amountInWFRXETHforFRAX);

        address[] memory path4;
        path4 = new address[](2);
        path4[0] = wfrxETH;
        path4[1] = fraxSTABLE;

        fraxswapRouter.swapExactTokensForTokens(
            amountInWFRXETHforFRAX, amountOutMinWFRXETHforFRAX, path4, msg.sender, block.timestamp
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