// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    address public owner;
    uint256 totalWaves;

    // we'll be using this below to generate random number
    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
    }

    Wave[] waves;

    /*
     * This is an address => uint mapping, meaning I can associate an address with a number!
     * In this case, I'll be storing the address with the last time the user waved at us.
     */
    mapping(address => uint256) public lastWavedTime;

    constructor() payable {
        owner = msg.sender;
        console.log(
            "Yo yo, The contract is fancy, make the NFT Certificate Fancy as well."
        );

        // set the initial seed
        seed = (block.timestamp + block.difficulty) % 100;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function wave(string memory _message) public {
        /*
         * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
         */
        require(
            lastWavedTime[msg.sender] + 15 minutes < block.timestamp,
            "wait 15m"
        );

        lastWavedTime[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved /w message %s", msg.sender, _message);

        waves.push(Wave(msg.sender, _message, block.timestamp));

        // generate a new seed for the next user that sends a wave
        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %d", seed);

        // give a 50% chance that the user wins the prize
        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            uint256 prizeAmount = 0.00001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We've %d total waves", totalWaves);
        return totalWaves;
    }
}
