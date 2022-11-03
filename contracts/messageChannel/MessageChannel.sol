// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMessageChannel {
    function send(
        uint256 toChainID,
        address to,
        bytes memory message
    ) external virtual;
}

interface IMessageClient {
    function onReceiveMessage(
        address caller,
        uint256 fromChainID,
        bytes memory message
    ) external virtual;
}

abstract contract MessageChannelBase is IMessageChannel {
    function onReceive(
        address client,
        address caller,
        uint256 fromChainID,
        bytes memory message
    ) internal {
        IMessageClient(client).onReceiveMessage(caller, fromChainID, message);
    }
}
