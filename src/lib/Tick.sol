// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

library Tick {
    struct Info {
        bool Iniitalized;
        uint128 liquiity;
    }

    function update(
        mapping(int24 => Tick.Info) storage self,
        int24 tick,
        uint128 liquidityDelta
    ) internal {
        Tick.Info storage tickInfo = self[tick];
        uint128 liquidityBefore = tickInfo.liquiity;
        uint128 liquidityAfter = liquidityBefore + liquidityDelta;

        if(liquidityBefore == 0){
            tickInfo.Iniitalized = true;
        }

        tickInfo.liquiity = liquidityAfter;

    }
}
