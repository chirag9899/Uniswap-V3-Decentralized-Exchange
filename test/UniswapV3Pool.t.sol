// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "./ERC20Mintable.sol";
import "../src/UniswapV3Pool.sol";

contract UniswapV3PoolTest is Test {
    ERC20Mintable token0;
    ERC20Mintable token1;
    UniswapV3Pool pool;
    function setup() public {
        token0 = new ERC20Mintable("Ether","ETH",18);
        token0 = new ERC20Mintable("Usdc","USDC",25);
    }

    function testMintSuccesss() public {
        
    }

}