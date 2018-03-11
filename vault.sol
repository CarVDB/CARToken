pragma solidity ^0.4.18;

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

interface TokenContract {
    function transfer(address _recipient, uint256 _amount) external returns (bool);
    function balanceOf(address _holder) external view returns (uint256);
}

contract Vault is Ownable {
    TokenContract private tkn;
    address public beneficiary;
    uint256 public lockUntil;

    modifier canRequest() {
        require((msg.sender == owner) || (msg.sender == beneficiary));
        _;
    }

    function Vault() public {
        tkn = TokenContract(0x0); //set the token contract address here
        beneficiary = msg.sender;
        lockUntil = now + 2 years;
    }

    function setBeneficiary(address _beneficiary) onlyOwner public {
        beneficiary = _beneficiary;
    }

    function requestTokens() canRequest public {
        uint256 tokenAmount;
        require(now > lockUntil);
        tokenAmount = tkn.balanceOf(beneficiary);
        require(tkn.transfer(beneficiary, tokenAmount));
        TokensRequested(beneficiary, tokenAmount);
    }

    event TokensRequested(address _beneficiary, uint256 _amount);

}
