//SPDX-License-Identifier: Unlicense
pragma solidity 0.7.0;

import "./interfaces/IBank.sol";
import "./interfaces/IPriceOracle.sol";
import "./interfaces/IERC20.sol";

contract Bank is IBank {

    address public ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    // Well this idea was complete crap !
    // address public HAK_ADDRESS = 0xBefeeD4CB8c6DD190793b1c97B72B60272f3EA6C;

    //mapping (address => uint) public balancesETH;
    //mapping (address => uint) public balancesHACK;
    // should've done it this way:
    mapping(address => Account) public ethAccounts;
    mapping(address => Account) public hakAccounts;

    //address private mPriceOracle;
    //address private mHakToken;
    // okay so here it is probably best to just cast it in the beginning
    IPriceOracle public immutable mPriceOracle;
    // and this one we should have converted,too
    IERC20 public immutable mHakToken;

    // copy paste from example solution
    // interest rate in percent
    uint256 constant DEPOSIT_INTEREST_RATE = 300;
    uint256 constant BORROW_INTEREST_RATE = 500;
    uint256 constant MIN_COLLATERAL_RATIO = 15000;
    uint256 constant HUNDRED_PERCENT = 10000;
    uint256 constant TOKEN_DECIMAL_PRECISION = 1e18;
    // over how many blocks the interest rate is applied
    uint256 constant INTEREST_RATE_PERIOD = 100;


    constructor(address _priceOracle, address _hakToken) {
        // probably good to do stuff like this
        require(_priceOracle != address(0));
        require(_hakToken != address(0));
        // and this is how you cast
        mPriceOracle = IPriceOracle(_priceOracle);
        mHakToken = IERC20(_hakToken);
    }


    function deposit(address token, uint256 amount)
        payable
        external
        override
        returns (bool) {
            // this is how you log if you have your own logger ?!
            //console.log("deposit:");
            //console.log("   token:  ", token);
            //console.log("   amount: ", amount);
            bool isEth = token == ETH_ADDRESS;

            Account storage account;
            if (isEth) {
                require(amount == msg.value, "msg.value != amount");
                account = ethAccounts[msg.sender];
            } else {
                require(token == address(mHakToken), "token not supported");
                account = hakAccounts[msg.sender];
            }
            // now we should have the right account for this token
            // well I did not get to the interest rate part
            _updateAccount(account, DEPOSIT_INTEREST_RATE);
            // credit new balance to the account
            // well, this is simple to understand
            // but we'd need to declare add ?!
            account.deposit = account.deposit+amount;

            // this one we got ;/
            emit Deposit(msg.sender, token, amount);

            if (!isEth) {
                // so this part we completely omited
                // I am just using the non-safe from orig. IF
                mHakToken.transferFrom(msg.sender, address(this), amount);
            }
            // else
            // already paid once the transaction goes through

            /*if(token==ETH_ADDRESS){
                // then the token to deposit is ETH
                 balancesETH[msg.sender]+=amount;
                 emit Deposit(msg.sender, token, msg.value);
            }else if(token==address(mHakToken)){
                balancesHACK[msg.sender]+=amount;
                emit Deposit(msg.sender, token, msg.value);
            }else{
                revert("token not supported");
            }*/
            return true;
        }

    function withdraw(address token, uint256 amount)
        external
        override
        returns (uint256) {
            /*if(token==ETH_ADDRESS){
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
            }*/
            return 0;
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
             bool isEth = token == ETH_ADDRESS;
            Account memory account;
            if (isEth)
                account = ethAccounts[msg.sender];
            else if (token == address(mHakToken))
                account = hakAccounts[msg.sender];
            else
                revert("unknown token");

            uint256 interest = _computeInterest(account, DEPOSIT_INTEREST_RATE);
            // again just use +=
            //return account.deposit.add(interest);
            return account.deposit+=interest;

            /*if(token==ETH_ADDRESS){
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
            }else if(token==address(mHakToken)){ 
                //return 0x0539;
                uint256 amount=balancesETH[msg.sender];
                return amount;
            }else{
                revert("token not supported");
            }*/
            return 0;
        }


        // copy paste from ex. solution
         /// Updates the interest of the account
        function _updateAccount(Account storage account, uint256 interestRate)
            internal{
            Account memory _account = account;
            //uint256 newInterest = _computeInterest(_account, interestRate);
            uint256 newInterest=0;
            account.lastInterestBlock = block.number;

            if (newInterest == account.interest)
                return;

            account.interest = newInterest;
        }

        // copy paste from ex. solution
         function _computeInterest(Account memory account, uint256 interestRate)internal view returns (uint256 interest){
            if (account.lastInterestBlock == 0 || account.lastInterestBlock >= block.number)
                return account.interest;

            // we have at least 1 block passed
            uint256 passedBlocks = block.number - account.lastInterestBlock;
            //console.log("   passedBlocks: ", passedBlocks);

            //uint256 interestFactor = passedBlocks.mul(interestRate) / INTEREST_RATE_PERIOD;
            uint256 interestFactor = passedBlocks*(interestRate) / INTEREST_RATE_PERIOD;
            //console.log("   interestRate         : ", interestRate);
            //console.log("   interestFactor       : ", interestFactor);
            if (interestFactor > 0) {
                interest = account.interest+
                    (interestFactor*(account.deposit)
                    /(HUNDRED_PERCENT));
            }
        }
}
