pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint totalWaves;

    //this is going to be a random number
    uint private seed;

    //create an event
    event NewWave(address indexed from, uint256 timestamp, string message);

    //create a struct (which is like an object normally) with some attrs
    struct Wave {
        address waver;
        string message;
        uint timestamp;
    }

    //create an array for all the waves
    Wave[] waves;

    //save address of user and the last time thry waved
    mapping (address => uint) public lastWave;

    mapping (address => uint) userWaveCount;

    constructor() payable {
        console.log("This is tofunmi's contract");

        //set initial seed
        seed = (block.timestamp + block.difficulty) % 100;
    }

    //wave passes a message as well
    function wave(string memory _message) public {

        //make sure the user hasnt waved in the last 1mins

        require(
            lastWave[msg.sender] + 60 seconds < block.timestamp,
            "wait a minute"
        );

        //record their new attempt
        lastWave[msg.sender] = block.timestamp;


        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        // to store the waves in the array
        waves.push(Wave(msg.sender, _message, block.timestamp));

        //new seed for the next user that waves
        seed = (block.difficulty + block.timestamp + seed) % 100;

        //set a 50% chance the user wins the prize;
        if (seed <= 50) {
            console.log('%s won!', msg.sender);
            console.log('random # generated', seed);

            //initialize a prize amount
            uint256 prizeAmount = 0.0001 ether;
            //make sure the prize is less than the contract's balance
            require(prizeAmount <= address(this).balance,"Trying to withdraw more money than the contract has.");
            //send the person some ETH
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");  
        }

        //this is where the new event is created for that wave
        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint) {
        console.log("We have %d total waves", totalWaves);
        return totalWaves;
    }

    function getUserWaveCount() public returns(uint) {
        console.log(userWaveCount[msg.sender]);
    }


}