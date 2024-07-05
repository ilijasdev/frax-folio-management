// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FraxswapV2Swap {
    // SETTING THE FRAXSWAP ROUTER ADDRESS AND THE OWNER
    address private owner;
    address private constant FRAXSWAP_ROUTER = 0x39cd4db6460d8B5961F73E997E86DdbB7Ca4D5F6;
    IFraxswapV1Router private fraxswapRouter = IFraxswapV1Router(FRAXSWAP_ROUTER);

    // SETTING THE WHITELISTED TOKENS
    address private constant wfrxETH = 0xFC00000000000000000000000000000000000006;
    address private constant fraxSTABLE = 0xFc00000000000000000000000000000000000001;
    address private constant dogeFXD = 0xdeBb8a79B025B2Fc2CA506F0c69497B60B91235C;


    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
    // Implement your swap functions here. First step is to approve the contract to spend the token.
    // Then take the whitelisted tokens as input and use another input parameter that will set trader desired percentages of the tokens

    // If trader want stable portfolio, convert 80% of ETH to fraxSTABLE, 5% to dogeFXD and 15% to wfrxETH
    // If trader want bluechip portfolio, convert 50% of ETH to fraxSTABLE, 5% to dogeFXD and 45% to wfrxETH
    // If trader is degen, convert 10% of ETH to fraxSTABLE, 80% to dogeFXD and 10% to wfrxETH

    function masterSwapper(uint bluechipAmount, uint stableAmount, uint degenAmount, string memory balanceOption) external payable onlyOwner {
        // Ensure the contract has approved the token transfer
        // and that amount is greater than zero
        if (bluechipAmount > 0) {
            IERC20(wfrxETH).approve(FRAXSWAP_ROUTER, bluechipAmount);
            IERC20(wfrxETH).transferFrom(msg.sender, address(this), bluechipAmount);
        }

        if (stableAmount > 0) {
            IERC20(fraxSTABLE).approve(FRAXSWAP_ROUTER, stableAmount);
            IERC20(fraxSTABLE).transferFrom(msg.sender, address(this), stableAmount);
        }

        if (degenAmount > 0) {
            IERC20(dogeFXD).approve(FRAXSWAP_ROUTER, degenAmount);
            IERC20(dogeFXD).transferFrom(msg.sender, address(this), degenAmount);
        }

        // Path addresses
        address[] memory fromETHtoStablesPath = new address[](2);
        fromETHtoStablesPath[0] = 0xFc00000000000000000000000000000000000001;
        fromETHtoStablesPath[1] = 0xFC00000000000000000000000000000000000006;

        address[] memory fromETHtoDegensPath = new address[](2);
        fromETHtoDegensPath[0] = 0xdeBb8a79B025B2Fc2CA506F0c69497B60B91235C;
        fromETHtoDegensPath[1] = 0xFC00000000000000000000000000000000000006;

        // Call the swap function on the Fraxswap router and swap everything to ETH
        fraxswapRouter.swapExactTokensForETH(stableAmount, 0, fromETHtoStablesPath, address(this), block.timestamp);
        fraxswapRouter.swapExactTokensForETH(degenAmount, 0, fromETHtoDegensPath, address(this), block.timestamp);

        // CHECK BALANCE OPTIONS + IF ASSET IS GREATER THAN ZERO AND SWAP ETH TO RESPECTIVE TOKENS
        if (keccak256(abi.encodePacked(balanceOption)) == keccak256(abi.encodePacked("stable")) && stableAmount > 0) {
            // Path addresses
            address[] memory stablesFinalPath = new address[](2);
            stablesFinalPath[0] = fromETHtoStablesPath[1];
            stablesFinalPath[1] = fromETHtoStablesPath[0];
            address[] memory degensFinalPath = new address[](2);
            degensFinalPath[0] = fromETHtoDegensPath[1];
            degensFinalPath[1] = fromETHtoDegensPath[0];

            // Swap 80% of ETH to fraxSTABLE, 5% to dogeFXD and leftover to wfrxETH
            fraxswapRouter.swapExactETHForTokens{value: msg.value * 80 / 100}(0, stablesFinalPath, address(this), block.timestamp);
            fraxswapRouter.swapExactETHForTokens{value: msg.value * 5 / 100}(0, degensFinalPath, address(this), block.timestamp);
        }

        if (keccak256(abi.encodePacked(balanceOption)) == keccak256(abi.encodePacked("bluechip")) && bluechipAmount > 0) {
            // Path addresses
            address[] memory stablesFinalPath = new address[](2);
            stablesFinalPath[0] = fromETHtoStablesPath[1];
            stablesFinalPath[1] = fromETHtoStablesPath[0];
            address[] memory degensFinalPath = new address[](2);
            degensFinalPath[0] = fromETHtoDegensPath[1];
            degensFinalPath[1] = fromETHtoDegensPath[0];

            // Swap 50% of ETH to fraxSTABLE, 5% to dogeFXD and leftover to wfrxETH
            fraxswapRouter.swapExactETHForTokens{value: msg.value * 50 / 100}(0, stablesFinalPath, address(this), block.timestamp);
            fraxswapRouter.swapExactETHForTokens{value: msg.value * 5 / 100}(0, degensFinalPath, address(this), block.timestamp);
        }

        if (keccak256(abi.encodePacked(balanceOption)) == keccak256(abi.encodePacked("degen")) && degenAmount > 0) {
            // Path addresses
            address[] memory stablesFinalPath = new address[](2);
            stablesFinalPath[0] = fromETHtoStablesPath[1];
            stablesFinalPath[1] = fromETHtoStablesPath[0];
            address[] memory degensFinalPath = new address[](2);
            degensFinalPath[0] = fromETHtoDegensPath[1];
            degensFinalPath[1] = fromETHtoDegensPath[0];

            // Swap 10% of ETH to fraxSTABLE, 80% to dogeFXD and leftover to wfrxETH
            fraxswapRouter.swapExactETHForTokens{value: msg.value * 10 / 100}(0, stablesFinalPath, address(this), block.timestamp);
            fraxswapRouter.swapExactETHForTokens{value: msg.value * 80 / 100}(0, degensFinalPath, address(this), block.timestamp);
        }

        // If anything is left in contract after swapping, send it back to the user
        if (address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function myGetAmountsOutWithTwamm(uint amountIn, address[] memory path) external view returns (uint[] memory) {
        return fraxswapRouter.getAmountsOutWithTwamm(amountIn, path);
    }

    // Implementation of strategies above

    // Function to call swapExactETHForTokens
    function mySwapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable onlyOwner {
        // Call the swap function on the Fraxswap router
        fraxswapRouter.swapExactETHForTokens{value: msg.value}(amountOutMin, path, to, deadline);
    }

    // Function to call mySwapExactTokensForETH
    function mySwapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external onlyOwner {
        // Ensure the contract has approved the token transfer
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        IERC20(path[0]).approve(FRAXSWAP_ROUTER, amountIn);

        // Call the swap function on the Fraxswap router
        fraxswapRouter.swapExactTokensForETH(amountIn, amountOutMin, path, to, deadline);
    }
}

// INTERFACE FOR THE FRAXSWAP v2 ROUTER

interface IFraxswapV1Router {
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsOutWithTwamm(
        uint amountIn, 
        address[] memory path
    ) external view returns (uint[] memory amounts);
}

// INTERFACE IERC20

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}