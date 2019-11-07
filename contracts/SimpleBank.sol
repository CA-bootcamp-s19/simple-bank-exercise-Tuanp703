/*
    This exercise has been updated to use Solidity version 0.5
    Breaking changes from 0.4 to 0.5 can be found here: 
    https://solidity.readthedocs.io/en/v0.5.0/050-breaking-changes.html
*/

pragma solidity ^0.5.0;

contract SimpleBank {

    //
    // State variables
    //
    
    /* Fill in the keyword. Hint: We want to protect our users balance from other contracts*/
    mapping (address => uint) private balances;
    
    /* Fill in the keyword. We want to create a getter function and allow contracts to be able to see if a user is enrolled.  */
    mapping (address => bool) public enrolled;

    /* Let's make sure everyone knows who owns the bank. Use the appropriate keyword for this*/
    address public owner;
    
    /* Modifer that check customer has been enrolled */
    modifier IsEnrolled() { 
        require(enrolled[msg.sender] == true);
        _;
    }    
    
    //
    // Events - publicize actions to external listeners
    //
    
    /* Add an argument for this event, an accountAddress */
    event LogEnrolled(
        address accountEnrolled
    );

    /* Add 2 arguments for this event, an accountAddress and an amount */
    event LogDepositMade(
        address accountDeposit,
        uint accountAmount
    );

    /* Create an event called LogWithdrawal */
    /* Add 3 arguments for this event, an accountAddress, withdrawAmount and a newBalance */
    event LogWithdrawal(
        address accountWithdrawal,
        uint withdrawAmount,
        uint newBalance
    );

    //
    // Functions
    //

    /* Use the appropriate global variable to get the sender of the transaction */
    constructor() public {
        /* Set the owner to the creator of this contract */
        owner = msg.sender;
    }

    // Fallback function - Called if other functions don't match call or
    // sent ether without data
    // Typically, called when invalid data is sent
    // Added so ether sent to this contract is reverted if the contract fails
    // otherwise, the sender's money is transferred to contract
    function() external payable {
        revert();
    }

    /// @notice Get balance
    /// @return The balance of the user
    // A SPECIAL KEYWORD prevents function from editing state variables;
    // allows function to run locally/off blockchain
    function getBalance() public view returns (uint) {
        /* Get the balance of the sender of this transaction */
        return balances[msg.sender];
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    // Emit the appropriate event
    function enroll() public returns (bool){
        require(enrolled[msg.sender] == false);   //require enrolled status of false (new customer)
        enrolled[msg.sender] = true;              //enrolled current customer
        emit LogEnrolled(msg.sender);           //emit customer address
        return enrolled[msg.sender];            //return enrolled status
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    // Add the appropriate keyword so that this function can receive ether
    // Use the appropriate global variables to get the transaction sender and value
    // Emit the appropriate event    
    // Users should be enrolled before they can make deposits
    function deposit() public payable IsEnrolled returns (uint) {
        /* Add the amount to the user's balance, call the event associated with a deposit,
          then return the balance of the user */
          // require(enrolled[msg.sender] == true);     //require customer to be enrolled as bank customer
          balances[msg.sender] += msg.value;         //deposit into customer's account
          emit LogDepositMade(msg.sender, msg.value); //emit DepositMade
          return balances[msg.sender];              //return current custoemr balance
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    // Emit the appropriate event    
    function withdraw(uint withdrawAmount) public payable IsEnrolled returns (uint) {
        /* If the sender's balance is at least the amount they want to withdraw,
           Subtract the amount from the sender's balance, and try to send that amount of ether
           to the user attempting to withdraw. 
           return the user's balance.*/
           //  require(enrolled[msg.sender] == true);       //require customer to be enrolled as bank customer
           assert(balances[msg.sender] >= withdrawAmount);      //the customer balance must be at least the withdrawAmount - use assert b/c all gases are consumed.
           balances[msg.sender] -= withdrawAmount;      //reduce customer balance by withdrawAmount
           address(msg.sender).transfer(withdrawAmount);    //transfer withdrawAmount
           emit LogWithdrawal(msg.sender, withdrawAmount, balances[msg.sender]);        //emit withdraw details
           return balances[msg.sender];     //show current customer balance after withdrawAmount deduction.
    }
}

