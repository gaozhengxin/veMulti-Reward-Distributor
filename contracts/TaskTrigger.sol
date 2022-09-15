// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Trigger {
    function doTask() internal virtual;

    function _beforeTriggered() internal virtual {}

    function _afterTriggered() internal virtual {}

    function triggerTask() external virtual {
        _beforeTriggered();
        doTask();
        _afterTriggered();
    }
}
