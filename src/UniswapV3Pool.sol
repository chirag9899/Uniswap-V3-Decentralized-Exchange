// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./lib/Tick.sol";
import "./lib/Position.sol";

import "./interfaces/IUniswapV3MintCallback.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC20.sol";

contract UniswapV3Pool {
    using Tick for mapping(int24 => Tick.Info);
    using Position for mapping(bytes32 => Position.Info);
    using Position for Position.Info;

    //event
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    //errors
    error invaliTickRange();
    error InsufficientInputAmount();

    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;

    // immutable pool token
    address public immutable token0;
    address public immutable token1;

    // packing var that are read together
    struct Slot0 {
        // current sqroot(p)
        uint160 sqrtPricex96;
        // current tick
        int24 tick;
    }
    Slot0 public slot0;

    //Amount of Liquiity
    uint128 public liquidity;

    //Tick-index to Tickinfo
    mapping(int24 => Tick.Info) public ticks;

    //unique position ientifier to position-info
    mapping(bytes32 => Position.Info) public positions;

    //constructor that init some var of our contract
    constructor(
        address _token0,
        address _token1,
        uint160 _sqrtPricex96,
        int24 _tick
    ) {
        token0 = _token0;
        token1 = _token1;
        slot0 = Slot0({sqrtPricex96: _sqrtPricex96, tick: _tick});
    }

    // Mint function take
    // @Owner’s address, to track the owner of the liquidity.
    // @Upper and lower ticks, to set the bounds of a price range.
    // @The amount of liquidity we want to provide.
    function mint(
        address owner,
        int24 lowerTick,
        int24 upperTick,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1) {
        // checks
        if (
            upperTick >= lowerTick ||
            lowerTick < MIN_TICK ||
            upperTick > MAX_TICK
        ) revert invaliTickRange();

        require(amount > 0, "zero liquidity");

        //Add a tick and a position mapping
        ticks.update(lowerTick, amount);
        ticks.update(upperTick, amount);

        Position.Info storage position = positions.get(
            owner,
            lowerTick,
            upperTick
        );

        position.update(amount);

        // Harcoded amounts that user must deposit.
        amount0 = 0.998976618347425280 ether;
        amount1 = 5000 ether;

        // Updating the liquidity of the pool
        liquidity += uint128(amount);

        uint256 balance0Before;
        uint256 balance1Before;
        if (amount0 > 0) {
            balance0Before = balance0();
        }
        if (amount1 > 0) {
            balance1Before = balance1();
        }

        IUniswapV3MintCallback(msg.sender).uniswapV3MintCallback(
            amount0,
            amount1,
            data
        );

        if(amount0 > 0 && balance0Before + amount0 > balance0() ){
            revert InsufficientInputAmount();
        }
        if(amount1 > 0 && balance1Before + amount1 > balance1() ){
            revert InsufficientInputAmount();
        }

         emit Mint(msg.sender, owner, lowerTick, upperTick, amount, amount0, amount1);
    }

    function balance0()internal view returns(uint256 balance) {
        balance = IERC20(token0).balanceOf(address(this));
    }
    
    function balance1()internal view returns(uint256 balance) {
        balance = IERC20(token1).balanceOf(address(this));
    }
}
