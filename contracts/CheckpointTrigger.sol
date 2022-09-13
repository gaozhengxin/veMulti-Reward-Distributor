// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TimedTaskTrigger.sol";

interface IVE {
    function checkpoint() external;
}

contract CheckpointTrigger is TimedTaskTrigger {
    address public ve;

    constructor (address _ve) {
        ve = _ve;
        uint256 peroid = 4 days;
        uint256 zeroTime = (block.timestamp / peroid) * peroid;
        uint256 window = 4 days;
        _initTimedTask(zeroTime, peroid, window);
    }

    function doTask() public override {
        IVE(ve).checkpoint();
    }
}