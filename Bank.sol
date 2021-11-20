//SPDX-License-Identifier: Unlicense
pragma solidity 0.7.0;

import "./interfaces/IBank.sol";
import "./interfaces/IPriceOracle.sol";

contract Bank is IBank {

    address public ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    // TODO still wrong
    // this is the first one : 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C
    address public HAK_ADDRESS = 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C;

    mapping (address => uint) public balancesETH;
    mapping (address => uint) public balancesHACK;

    address private mPriceOracle;
    address private mHakToken;

    constructor(address _priceOracle, address _hakToken) {
         mPriceOracle=_priceOracle;
         mHakToken=_hakToken;
    }


    function deposit(address token, uint256 amount)
        payable
        external
        override
        returns (bool) {
            if(token==ETH_ADDRESS){
                // then the token to deposit is ETH
                 balancesETH[msg.sender]+=amount;
                 emit Deposit(msg.sender, token, msg.value);
            }else if(token==mHakToken){
                balancesHACK[msg.sender]+=amount;
                emit Deposit(msg.sender, token, msg.value);
            }else{
                revert("token not supported");
            }
        }

    function withdraw(address token, uint256 amount)
        external
        override
        returns (uint256) {
            if(token==ETH_ADDRESS){
                uint256 balance=balancesETH[msg.sender];
                if(balance<=0){
                     revert("no balance");
                }
                if(balance<amount){
                    revert("amount exceeds balance");
                }
                 balancesETH[msg.sender] -= amount;
                 return amount;
            }else{
                revert("token not supported");
            }
        }

    function borrow(address token, uint256 amount)
        external
        override
        returns (uint256) {
           if(token==ETH_ADDRESS){
                return 0;
            }else{
                revert("token not supported");
            }
        }

    function repay(address token, uint256 amount)
        payable
        external
        override
        returns (uint256) {
            if(token==ETH_ADDRESS){
                return 0;
            }else{
                revert("token not supported");
            }
        }

    function liquidate(address token, address account)
        payable
        external
        override
        returns (bool) {
            if(token==ETH_ADDRESS){
                return false;
            }else{
                revert("token not supported");
            }
        }

    function getCollateralRatio(address token, address account)
        view
        public
        override
        returns (uint256) {
            return 0;
        }

    function getBalance(address token)
        view
        public
        override
        returns (uint256) {
            if(token==ETH_ADDRESS){
                 //return  balancesETH[token];
            //return 0x8ac7230489e80000;

            uint256 amount=balancesETH[msg.sender];
            uint256 price=IPriceOracle(mPriceOracle).getVirtualPrice(token);

            //return amount*price /(10^18);
            return amount;
            //return amount/6;

            //return price;
            //return balancesETH[token]*IPriceOracle(mPriceOracle).getVirtualPrice(token)/(10^17);

            //DSMath.
            }else if(token==mHakToken){ 
                //return 0x0539;
                uint256 amount=balancesETH[msg.sender];
                return amount;
            }else{
                revert("token not supported");
            }
        }
}
