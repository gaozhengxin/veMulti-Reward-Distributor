// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Pseudo ve contract for testing purposes
 * auto checkpoint
 * reward distributor
 */
contract ve {
    event Checkpoint(uint256 timestamp);

    function checkpoint() external {
        emit Checkpoint(block.timestamp);
    }

    uint256 _totalSupply = 1000000000000000000000000;

    function totalSupplyAtT(uint256 t) external view returns (uint256) {
        return _totalSupply - t;
    }

    function setTotalSupply(uint256 value) external {
        _totalSupply = value;
    }
}