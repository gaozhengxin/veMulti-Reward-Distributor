// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TaskTrigger.sol";

abstract contract TimedTaskTrigger is Trigger {
    uint256 public zeroTime;
    uint256 public peroid;
    uint256 public window;

    function _initTimedTask(
        uint256 zeroTime_,
        uint256 peroid_,
        uint256 window_
    ) internal {
        zeroTime = zeroTime_;
        peroid = peroid_;
        window = window_;
    }

    uint256 public lastTriggerTime;

    function currentPeroid() view public returns (uint256) {
        return (block.timestamp - zeroTime) / peroid;
    }

    function _beforeTriggered() public override {
        uint256 currentPeroid_ = currentPeroid();
        require(lastTriggerTime < currentPeroid_ * peroid, "already triggered");

        uint256 start = (uint256(currentPeroid_)) * peroid + zeroTime;
        uint256 end = start + window;
        require(block.timestamp >= start && block.timestamp < end, "currently not available");

        this._beforeTriggered();
    }

    function _afterTriggered() public override {
        lastTriggerTime = block.timestamp;

        this._afterTriggered();
    }

    function triggerTask() override external {
        this.triggerTask();
    }
}
