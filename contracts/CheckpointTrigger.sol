// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TimedTaskTrigger.sol";

interface IVE {
    function checkpoint() external;
}

contract CheckpointTrigger is TimedTaskTrigger {
    address public ve;

    /// @param _ve ve contract address
    /// @param interval inteval length in second
    constructor (address _ve, uint256 interval) {
        ve = _ve;
        uint256 zeroTime = (block.timestamp / interval) * peroid;
        uint256 window = interval;
        _initTimedTask(zeroTime, interval, window);
    }

    function doTask() public override {
        IVE(ve).checkpoint();
    }
}