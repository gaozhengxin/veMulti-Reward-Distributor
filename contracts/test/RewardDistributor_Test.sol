// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../TimedTaskTrigger.sol";
import "../AnyCallApp.sol";

interface IVE {
    function totalSupplyAtT(uint256 t) external view returns (uint256); // query total power at a future time
}

interface IReward {
    function addEpoch(uint startTime, uint endTime, uint totalReward) external returns(uint, uint);
}

contract RewardDistributor_Test is TimedTaskTrigger, AnyCallApp {
    address public ve;
    address public reward; // AdminCallModifier
    uint256 constant HOUR = 1 hours;
    uint256[] public destChains;
    mapping(uint256 => uint256) public totalReward; // week -> totalReward

    struct Power {
        uint256 week;
        uint256 value;
    }

    Power public power;

    mapping(uint256 => Power) public peerPowers;

    event TotalReward(uint256 totalReward);
    event SetReward(uint256 epochId, uint256 accurateTotalReward);

    constructor(address _ve, address _reward, uint256[] memory destChains_, address anyCallProxy) AnyCallApp(anyCallProxy, 2) {
        setAdmin(msg.sender);
        ve = _ve;
        reward = _reward;
        uint256 peroid = HOUR;
        uint256 zeroTime = (block.timestamp / HOUR + 1) * HOUR - 600;
        uint256 window = 300;
        _initTimedTask(zeroTime, peroid, window);
        destChains = destChains_;
    }

    function snapshotTime() public view returns (uint256) {
        return (block.timestamp / HOUR + 1) * HOUR;
    }

    function setTotalReward(uint256[] calldata weekNums, uint256 _totalReward) external onlyAdmin {
        for (uint i = 0; i < weekNums.length; i++) {
            totalReward[weekNums[i]] = _totalReward;
        }
    }

    function doTask() public override {
        // query total power
        power = Power(
            block.timestamp / HOUR + 1,
            IVE(ve).totalSupplyAtT(snapshotTime())
        );
        // send anycall message
        bytes memory acmsg = abi.encode(power);
        for (uint i = 0; i < destChains.length; i++) {
            _anyCall(peer[destChains[i]], acmsg, address(0), destChains[i]);
        }
    }

    function _anyExecute(uint256 fromChainID, bytes calldata data)
        internal
        override
        returns (bool success, bytes memory result)
    {
        assert(power.week == block.timestamp / HOUR + 1);
        Power memory peerPower = abi.decode(data, (Power));
        peerPowers[fromChainID] = peerPower;
        // check all arrived
        uint256 totalPower = 0;
        for (uint i = 0; i < destChains.length; i++) {
            if (peerPowers[destChains[i]].week != power.week) {
                return (true, "");
            }
            totalPower += peerPowers[destChains[i]].value;
        }
        emit TotalReward(totalPower);
        // set reward
        uint start = (power.week) * HOUR;
        uint end = start + HOUR;
        uint rewardi = power.value * totalReward[power.week] / totalPower;
        // set reward
        (uint epochId, uint accurateTotalReward) = IReward(reward).addEpoch(start, end, rewardi);
        emit SetReward(epochId, accurateTotalReward);
        return (true, "");
    }
}
