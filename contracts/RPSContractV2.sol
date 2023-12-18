// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RPSContractV2 is Ownable {
    using SafeMath for uint256;

    event StakePaid(address indexed _from, uint _value);
    event StakeRefunded(address indexed _to, uint _value);
    event WinnerDecided(address indexed _winner, uint _value);
    event DrawGame(
        address indexed _player1,
        uint _stake1,
        address indexed _player2,
        uint _stake2
    );
    event ContractLiquidated(address indexed _payee, uint _value);
    event Log(string message, uint _value);

    mapping(string => mapping(address => string)) public gameMoveHashes;

    function getPlayerMoveHash(
        string memory _gameId,
        address _playerAddress
    ) public view returns (string memory) {
        return gameMoveHashes[_gameId][_playerAddress];
    }

    // function set(
    //     string memory _gameId,
    //     address _playerAddress,
    //     string memory _hash
    // ) public onlyOwner {
    //     gameMoveHashes[_gameId][_playerAddress] = _hash;
    // }

    function removePlayerMoveHash(
        string memory _gameId,
        address _playerAddress
    ) public onlyOwner {
        delete gameMoveHashes[_gameId][_playerAddress];
    }

    function payStake(
        string memory _gameId,
        address _playerAddress,
        string memory _hash
    ) public payable {
        require(msg.value > 0, "Must stake a positive amount of ether");

        gameMoveHashes[_gameId][_playerAddress] = _hash;

        emit StakePaid(msg.sender, msg.value);
    }

    function refundWager(
        address payable _payee,
        uint256 _amount,
        uint256 _fees,
        string memory _gameId
    ) public payable onlyOwner {
        emit Log(string(abi.encodePacked("Fees for game: ", _gameId)), _fees);

        uint256 refundAmount = _amount.sub(_fees);

        _payee.transfer(refundAmount);

        emit StakeRefunded(_payee, refundAmount);
    }

    function payWinner(
        address payable winner,
        uint256 _player1Stake,
        uint256 _player2Stake,
        uint256 _fees,
        string memory _gameId
    ) public onlyOwner {
        emit Log(string(abi.encodePacked("Fees for game: ", _gameId)), _fees);

        uint256 winnerPrize = _player1Stake.add(_player2Stake).sub(_fees);

        winner.transfer(winnerPrize);
        emit WinnerDecided(winner, winnerPrize);
    }

    function payDraw(
        address payable _player1,
        address payable _player2,
        uint256 _player1Stake,
        uint256 _player2Stake,
        uint256 _fees,
        string memory _gameId
    ) public onlyOwner {
        emit Log(string(abi.encodePacked("Fees for game: ", _gameId)), _fees);

        uint256 player1DrawPrize = _player1Stake.sub(_fees);
        uint256 player2DrawPrize = _player2Stake.sub(_fees);

        _player1.transfer(player1DrawPrize);
        _player2.transfer(player2DrawPrize);

        emit DrawGame(_player1, player1DrawPrize, _player2, player2DrawPrize);
    }

    // function to withdraw all funds from the contract to the owner's address
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
        emit ContractLiquidated(msg.sender, balance);
    }

    function getBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }
}
