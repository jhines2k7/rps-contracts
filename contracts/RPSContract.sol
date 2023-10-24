// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RPSContract is Ownable{
  using SafeMath for uint256;

  address payable private arbiter;
  uint256 private arbiterFeePercentage;

  event StakePaid(address indexed _from, uint _value);
  event StakeRefunded(address indexed _to, uint _value);
  event WinnerDecided(address indexed _winner, uint _value);
  event Draw(address indexed _player1, address indexed _player2, uint _stake1, uint _stake2);
  event ContractLiquidated(address indexed _payee, uint _value);
  event Log(string message, uint _value);

  constructor(uint256 _arbiterFeePercentage, address payable _arbiter) Ownable(){
    arbiterFeePercentage = _arbiterFeePercentage;
    arbiter = _arbiter;
  }

  function payStake() public payable {    
    require(msg.value > 0, "Must stake a positive amount of ether");

    emit StakePaid(msg.sender, msg.value);
  }

  function refundWager(address payable _payee, uint256 _amount) public payable onlyOwner {
    _payee.transfer(_amount);

    emit StakeRefunded(_payee, _amount);
    emit Log("Contract balance after refund ", address(this).balance);
  }

  function calculateStakes(uint256 _player1Stake, uint256 _player2Stake) internal returns (uint256, uint256) {
    emit Log("Total stake for this game", _player1Stake.add(_player2Stake));
    uint256 stake1ArbiterFee = _player1Stake.mul(arbiterFeePercentage).div(10000);
    emit Log("Stake 1 arbiter fee ", stake1ArbiterFee);
    uint256 stake2ArbiterFee = _player2Stake.mul(arbiterFeePercentage).div(10000);
    emit Log("Stake 2 arbiter fee ", stake2ArbiterFee);

    uint256 arbiterFee = stake1ArbiterFee.add(stake2ArbiterFee);
    emit Log("Arbiter fee calculated for game", arbiterFee);

    arbiter.transfer(arbiterFee);

    return (stake1ArbiterFee, stake2ArbiterFee);
  }

  function payWinner(address payable winner, uint256 _player1Stake, uint256 _player2Stake) public onlyOwner {
    // (uint256 stake1ArbiterFee, uint256 stake2ArbiterFee) = calculateStakes(_player1Stake, _player2Stake);
    emit Log("Total stake for this game", _player1Stake.add(_player2Stake));
    uint256 stake1ArbiterFee = _player1Stake.mul(arbiterFeePercentage).div(10000);
    emit Log("Stake 1 arbiter fee ", stake1ArbiterFee);
    uint256 stake2ArbiterFee = _player2Stake.mul(arbiterFeePercentage).div(10000);
    emit Log("Stake 2 arbiter fee ", stake2ArbiterFee);

    uint256 arbiterFee = stake1ArbiterFee.add(stake2ArbiterFee);
    emit Log("Arbiter fee calculated for game", arbiterFee);

    arbiter.transfer(arbiterFee);

    uint256 winnerPrize = _player1Stake.sub(stake1ArbiterFee).add(_player2Stake).sub(stake2ArbiterFee);
    emit Log("Winner prize ", winnerPrize);
    winner.transfer(winnerPrize);
    emit WinnerDecided(winner, winnerPrize);
  }

  function payDraw(address payable _player1, address payable _player2, uint256 _player1Stake, uint256 _player2Stake) public onlyOwner {
    // (uint256 stake1ArbiterFee, uint256 stake2ArbiterFee) = calculateStakes(_player1Stake, _player2Stake);
    emit Log("Total stake for this game", _player1Stake.add(_player2Stake));
    uint256 stake1ArbiterFee = _player1Stake.mul(arbiterFeePercentage).div(10000);
    emit Log("Stake 1 arbiter fee ", stake1ArbiterFee);
    uint256 stake2ArbiterFee = _player2Stake.mul(arbiterFeePercentage).div(10000);
    emit Log("Stake 2 arbiter fee ", stake2ArbiterFee);

    uint256 arbiterFee = stake1ArbiterFee.add(stake2ArbiterFee);
    emit Log("Arbiter fee calculated for game", arbiterFee);

    arbiter.transfer(arbiterFee);

    uint256 player1Prize = _player1Stake.sub(stake1ArbiterFee);
    uint256 player2Prize = _player2Stake.sub(stake2ArbiterFee);

    _player1.transfer(player1Prize);
    _player2.transfer(player2Prize);

    emit Draw(_player1, _player2, player1Prize, player2Prize);
  }

  function liquidateContract() public onlyOwner {
    uint256 contractBalance = address(this).balance;
    arbiter.transfer(contractBalance);
    emit ContractLiquidated(arbiter, contractBalance);
  }

  function getBalance() public onlyOwner view returns (uint256) {
    return address(this).balance;
  }
}
