// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RPSContract is Ownable{
  using SafeMath for uint256;

  event StakePaid(address indexed _from, uint _value);
  event StakeRefunded(address indexed _to, uint _value);
  event WinnerDecided(address indexed _winner, uint _value);
  event Draw(address indexed _player1, uint _stake1, address indexed _player2, uint _stake2);
  event ContractLiquidated(address indexed _payee, uint _value);
  event Log(string message, uint _value);

  function payStake() public payable {    
    require(msg.value > 0, "Must stake a positive amount of ether");

    emit StakePaid(msg.sender, msg.value);
  }

  function refundWager(address payable _payee, 
                        uint256 _amount, 
                        uint256 _feeMarkup, 
                        string memory _gameId) public payable onlyOwner {
    emit Log(string(abi.encodePacked("Refund markup for game: ", _gameId)), _feeMarkup);

    _payee.transfer(_amount.sub(_feeMarkup));

    emit StakeRefunded(_payee, _amount.sub(_feeMarkup));
    emit Log("Contract balance after refund ", address(this).balance);
  }

  function payWinner(address payable winner, 
                      uint256 _player1Stake, 
                      uint256 _player2Stake,
                      uint256 _feeMarkup,
                      string memory _gameId) public onlyOwner {
    emit Log(string(abi.encodePacked("Fee markup for game winner: ", _gameId)), _feeMarkup);

    uint256 winnerPrize = _player1Stake.add(_player2Stake).sub(_feeMarkup);
    emit Log("Winner prize ", winnerPrize);
    winner.transfer(winnerPrize);
    emit WinnerDecided(winner, winnerPrize);
  }

  function payDraw(address payable _player1, 
                  address payable _player2, 
                  uint256 _player1Stake, 
                  uint256 _player2Stake,
                  uint256 _feeMarkup,
                  string memory _gameId) public onlyOwner {
    emit Log(string(abi.encodePacked("Fee markup for game draw: ", _gameId)), _feeMarkup);

    uint256 player1Prize = _player1Stake.sub(_feeMarkup);
    uint256 player2Prize = _player2Stake.sub(_feeMarkup);

    _player1.transfer(player1Prize);
    _player2.transfer(player2Prize);

    emit Draw(_player1, player1Prize, _player2, player2Prize);
  }

  // function to withdraw all funds from the contract to the owner's address
  function withdraw() public onlyOwner {
    uint256 balance = address(this).balance;
    payable(owner()).transfer(balance);
    emit ContractLiquidated(msg.sender, balance);
  }

  function getBalance() public onlyOwner view returns (uint256) {
    return address(this).balance;
  }
}
