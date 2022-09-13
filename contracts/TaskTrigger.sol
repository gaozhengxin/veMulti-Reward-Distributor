// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Trigger {
    function doTask() public virtual;
    function _beforeTriggered() public virtual;
    function _afterTriggered() public virtual;

    function triggerTask() external virtual {
        doTask();
        _afterTriggered();
    }
}