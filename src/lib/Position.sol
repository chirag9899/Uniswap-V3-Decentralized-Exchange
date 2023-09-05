// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

library Position {
    struct Info {
        uint128 liquiity;
    }

    function get(
        mapping(bytes32 => Info) storage self,
        address owner,
        int24 upperTick,
        int24 lowerTick
    )internal view returns(Position.Info storage position) {
        position = self[keccak256(abi.encodePacked(owner,upperTick,lowerTick))];
    }

    function update(
        Info storage self,
        uint128 liquidityDelta
    )internal {
        uint128 liquidityBefore = self.liquiity;
        uint128 liquidityAfter = liquidityBefore + liquidityDelta;

        self.liquiity = liquidityAfter;
    }
}
