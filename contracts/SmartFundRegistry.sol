pragma solidity ^0.4.24;

import "./SmartFund.sol";
import "./PermittedExchangesInterface.sol";
import "./zeppelin-solidity/contracts/ownership/Ownable.sol";

/*
* The SmartFundRegistry is used to manage the creation and permissions of SmartFund contracts
*/
contract SmartFundRegistry is Ownable {
  SmartFund[] public smartFunds;

  // The Smart Contract which stores the addresses of all the authorized Exchange Portals
  PermittedExchangesInterface public permittedExchanges;

  address public exchangePortalAddress;
  address public permittedExchangesAddress;

  // platForm fee is out of 10,000, e.g 2500 is 25%
  uint256 public platformFee;

  // Default maximum success fee is 3000/30%
  uint256 public maximumSuccessFee = 3000;

  event SmartFundAdded(address indexed smartFundAddress, address indexed owner);

  /**
  * @dev contructor
  *
  * @param _platformFee                  Initial platform fee
  * @param _exchangePortalAddress        Address of the initial ExchangePortal contract
  * @param _permittedExchangesAddress    Address of the permittedExchanges contract
  */
  constructor(
    uint256 _platformFee,
    address _exchangePortalAddress,
    address _permittedExchangesAddress
  ) public {
    platformFee = _platformFee;
    exchangePortalAddress = _exchangePortalAddress;
    permittedExchangesAddress = _permittedExchangesAddress;
  }

  /**
  * @dev Creates a new SmartFund
  *
  * @param _name          The name of the new fund
  * @param _successFee    The fund managers success fee
  */
  function createSmartFund(string _name, uint256 _successFee) public {
    
    // Require that the funds success fee be less than the maximum allowed amount
    require(_successFee <= maximumSuccessFee);

    address owner = msg.sender;

    SmartFund smartFund = new SmartFund(
      owner,
      _name,
      _successFee,
      platformFee,
      this,
      exchangePortalAddress,
      permittedExchangesAddress
    );
    
    smartFunds.push(smartFund);

    emit SmartFundAdded(address(smartFund), owner);
  }

  function totalSmartFunds() public view returns (uint256) {
    return smartFunds.length;
  }

  function getAllSmartFundAddresses() public view returns(address[]) {
    address[] memory addresses = new address[](smartFunds.length);

    for (uint i; i < smartFunds.length; i++) {
      addresses[i] = address(smartFunds[i]);
    }

    return addresses;
  }

  /**
  * @dev Sets a new default ExchangePortal address
  *
  * @param _newExchangePortalAddress    Address of the new exchange portal to be set
  */
  function setExchangePortalAddress(address _newExchangePortalAddress) public onlyOwner {
    // Require that the new exchange portal is permitted by permittedExchanges
    require(permittedExchanges.permittedAddresses(_newExchangePortalAddress));
    exchangePortalAddress = _newExchangePortalAddress;
  }

  /**
  * @dev Sets maximum success fee for all newly created SmartFunds
  *
  * @param _maximumSuccessFee    New maximum success fee
  */
  function setMaximumSuccessFee(uint256 _maximumSuccessFee) external onlyOwner {
    maximumSuccessFee = _maximumSuccessFee;
  }

  /**
  * @dev Sets platform fee for all newly created SmartFunds
  *
  * @param _platformFee    New platform fee
  */
  function setPlatformFee(uint256 _platformFee) external onlyOwner {
    platformFee = _platformFee;
  }

  /**
  * @dev Allows platform to withdraw tokens received as part of the platform fee
  *
  * @param _tokenAddress    Address of the token to be withdrawn
  */
  function withdrawTokens(address _tokenAddress) external onlyOwner {
    ERC20 token = ERC20(_tokenAddress);

    token.transfer(owner, token.balanceOf(this));
  }

  /**
  * @dev Allows platform to withdraw ether received as part of the platform fee
  */
  function withdrawEther() external onlyOwner {
    owner.transfer(address(this).balance);
  }

  // Fallback payable function in order to receive ether when fund manager withdraws their cut
  function() public payable {}

}
