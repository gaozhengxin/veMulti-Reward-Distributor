// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TimedTaskTrigger.sol";
import "./messageChannel/MessageChannel.sol";
import "./Administrable.sol";

interface IVE {
    function totalSupplyAtT(uint256 t) external view returns (uint256); // query total power at a future time
}

interface IReward {
    function addEpoch(
        uint256 startTime,
        uint256 endTime,
        uint256 totalReward
    ) external returns (uint256, uint256);
}

contract RewardDistributor is TimedTaskTrigger, Administrable, IMessageClient {
    address public ve;
    address public reward; // AdminCallModifier
    uint256 constant interval = 1 weeks;
    uint256[] public destChains;
    IMessageChannel public messageChannel;
    mapping(uint256 => uint256) public totalReward; // epoch -> totalReward

    struct Power {
        uint256 epoch;
        uint256 value;
    }

    Power public power;
    mapping(uint256 => address) public peer;

    mapping(uint256 => Power) public peerPowers;

    event TotalReward(uint256 totalReward);
    event SetReward(uint256 epochId, uint256 accurateTotalReward);
    event LatestReward(uint256 accurateTotalReward);

    constructor(
        address _ve,
        address _reward,
        uint256[] memory destChains_
    ) {
        setAdmin(msg.sender);
        ve = _ve;
        reward = _reward;
        uint256 zeroTime = (block.timestamp / interval + 1) *
            interval -
            3600 *
            12;
        uint256 window = 3600 * 6;
        uint256 peroid = 1 weeks;
        _initTimedTask(zeroTime, peroid, window);
        destChains = destChains_;
    }

    function setMessageChannel(address messageChannel_) public onlyAdmin {
        messageChannel = IMessageChannel(messageChannel_);
    }

    function setPeer(uint256 chain, address peer_) public onlyAdmin {
        peer[chain] = peer_;
    }

    function snapshotTime() public view returns (uint256) {
        return (block.timestamp / interval + 1) * interval;
    }

    function setTotalReward(uint256[] calldata epochNums, uint256 _totalReward)
        external
        onlyAdmin
    {
        for (uint256 i = 0; i < epochNums.length; i++) {
            totalReward[epochNums[i]] = _totalReward;
        }
    }

    function currentEpoch() public view returns (uint256) {
        return block.timestamp / interval + 1;
    }

    function doTask() internal override {
        // query total power
        power = Power(
            block.timestamp / interval + 1,
            IVE(ve).totalSupplyAtT(snapshotTime())
        );
        // send anycall message
        bytes memory acmsg = abi.encode(power);
        for (uint256 i = 0; i < destChains.length; i++) {
            messageChannel.send(destChains[i], peer[destChains[i]], acmsg);
        }
    }

    function onReceiveMessage(
        address caller,
        uint256 fromChainID,
        bytes memory message
    ) external override {
        require(peer[fromChainID] == caller);
        assert(power.epoch == block.timestamp / interval + 1);
        Power memory peerPower = abi.decode(message, (Power));
        peerPowers[fromChainID] = peerPower;
        // check all arrived
        uint256 totalPower = power.value;
        for (uint256 i = 0; i < destChains.length; i++) {
            if (peerPowers[destChains[i]].epoch != power.epoch) {
                return;
            }
            totalPower += peerPowers[destChains[i]].value;
        }
        emit TotalReward(totalPower);
        // set reward
        uint256 start = (power.epoch) * interval;
        uint256 end = start + interval;
        uint256 rewardi = (power.value * totalReward[power.epoch]) / totalPower;
        // set reward
        /*(uint256 epochId, uint256 accurateTotalReward) = IReward(reward)
            .addEpoch(start, end, rewardi);*/
        //emit SetReward(epochId, accurateTotalReward);
        emit LatestReward(rewardi);
        return;
    }
}
