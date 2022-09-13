// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Reward {
    struct RewardInfo {
        uint256 startTime;
        uint256 endTime;
        uint256 totalReward;
    }

    RewardInfo public rewardInfo;

    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function setAdmin(address _admin) external onlyAdmin {
        admin = _admin;
    }

    function addEpoch(uint startTime, uint endTime, uint totalReward) external onlyAdmin returns(uint, uint) {
        rewardInfo = RewardInfo(startTime, endTime, totalReward);
        return (1,1);
    }
}