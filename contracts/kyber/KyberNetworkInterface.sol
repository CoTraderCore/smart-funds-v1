pragma solidity ^0.4.24;

import "../zeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract KyberNetworkInterface {
  function trade(
    ERC20 src,
    uint srcAmount,
    ERC20 dest,
    address destAddress,
    uint maxDestAmount,
    uint minConversionRate,
    address walletId
  )
    public
    payable
    returns(uint);

  function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) public view
    returns (uint expectedRate, uint slippageRate);
}