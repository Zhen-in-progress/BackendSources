// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;
contract Voting {
    mapping(address => uint256) public res;
    address[] public votedUsers;

    function vote(address user) external{
        if (res[user]==0){
            votedUsers.push(user);
        }
        res[user]+=1;
    }
    function getVote(address user) external view returns (uint256){
        return res[user];
    }
    function resetVotes() external {
        for (uint i = 0; i < votedUsers.length; i++){
            res[votedUsers[i]] = 0;
        }
    }
}
