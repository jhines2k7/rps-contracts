// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RPSContract is Ownable{
  using SafeMath for uint256;

  address payable private arbiter;
  uint256 private stake;
  uint256 private arbiterFee;
  uint256 private arbiterFeePercentage;
  uint256 private contractBalance;

  event StakePaid(address indexed _from, uint _value);
  event StakeRefunded(address indexed _to, uint _value);
  event WinnerDecided(address indexed _winner, uint _value);
  event Draw(address indexed _player1, address indexed _player2, uint _stake1, uint _stake2);
  event ContractLiquidated(address indexed _payee, uint _value);
  event Log(string message, uint _value);

  constructor(uint256 _arbiterFeePercentage) Ownable(){
    arbiterFeePercentage = _arbiterFeePercentage;
  }

  function joinGame() public payable {    
    require(msg.value > 0, "Must stake a positive amount of ether");

    emit StakePaid(msg.sender, msg.value);

    contractBalance += msg.value;
  }

  function refundWager(address payable payee) public payable onlyOwner {
    payee.transfer(msg.value);
    emit StakeRefunded(payee, msg.value);

    contractBalance -= msg.value;
    emit Log("Contract balance after refund ", contractBalance);
  }

  function payWinner(address payable winner, uint256 _stake1, uint256 _stake2) public onlyOwner {
    emit Log("Total stake for this game", _stake1.add(_stake2));
    uint256 stake1ArbiterFee = _stake1.mul(arbiterFeePercentage).div(10000);
    emit Log("Stake 1 arbiter fee ", stake1ArbiterFee);
    uint256 stake2ArbiterFee = _stake2.mul(arbiterFeePercentage).div(10000);
    emit Log("Stake 2 arbiter fee ", stake2ArbiterFee);

    uint256 winnerPrize = _stake1.sub(stake1ArbiterFee).add(_stake2).sub(stake2ArbiterFee);
    arbiterFee = stake1ArbiterFee.add(stake2ArbiterFee);
    emit Log("Arbiter fee calculated for winner", arbiterFee);

    arbiter.transfer(arbiterFee);
    contractBalance -= arbiterFee;

    emit Log("Winner prize ", winnerPrize);
    winner.transfer(winnerPrize);
    emit WinnerDecided(winner, winnerPrize);

    contractBalance -= winnerPrize;
  }

  function payDraw(address payable _player1, address payable _player2, uint256 _stake1, uint256 _stake2) public onlyOwner {
    uint256 stake1ArbiterFee = _stake1.mul(arbiterFeePercentage).div(10000);
    emit Log("Stake 1 arbiter fee ", stake1ArbiterFee);
    uint256 stake2ArbiterFee = _stake2.mul(arbiterFeePercentage).div(10000);
    emit Log("Stake 2 arbiter fee ", stake2ArbiterFee);

    arbiterFee = stake1ArbiterFee.add(stake2ArbiterFee);
    emit Log("Arbiter fee calculated for draw", arbiterFee);

    arbiter.transfer(arbiterFee);
    contractBalance -= arbiterFee;

    uint256 player1Prize = _stake1.sub(stake1ArbiterFee);
    uint256 player2Prize = _stake2.sub(stake2ArbiterFee);

    _player1.transfer(player1Prize);
    contractBalance -= player1Prize;

    _player2.transfer(player2Prize);
    contractBalance -= player2Prize;

    emit Draw(_player1, _player2, player1Prize, player2Prize);
  }

  function setArbiter(address payable _arbiter) public onlyOwner {
    arbiter = _arbiter;
  }

  function liquidateContract(address payable _arbiter) public onlyOwner {
    _arbiter.transfer(contractBalance);
    contractBalance = 0;
    emit ContractLiquidated(_arbiter, contractBalance);
  }
}
