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
        require(window_ <= peroid_, "invalid time params");
        zeroTime = zeroTime_;
        peroid = peroid_;
        window = window_;
    }

    uint256 public lastTriggerTime;

    function currentPeroid() view public returns (uint256) {
        if (block.timestamp < zeroTime) {
            return 1;
        }
        return (block.timestamp - zeroTime) / peroid + 1;
    }

    function _beforeTriggered() internal override {
        super._beforeTriggered();
    
        uint256 currentPeroid_ = currentPeroid();

        uint256 start = (currentPeroid_ - 1) * peroid + zeroTime;
        uint256 end = start + window;
        require(lastTriggerTime < start, "already triggered");
        require(block.timestamp >= start && block.timestamp < end, "currently not available");
    }

    function _afterTriggered() internal override {
        lastTriggerTime = block.timestamp;

        super._afterTriggered();
    }
}
