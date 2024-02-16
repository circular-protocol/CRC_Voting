/******************************************************************************************
*
*         Circular Protocol
*         Smart Contract Standard utilities definitions 
*         January 2024
*
*******************************************************************************************/

/**
 *  Smart Contract Version
 *
 */
var _Contract_Version;

/* Smart Contract Output Management *******************************************************/

/** 
 *  Output Global Variable
 *
 */
var _Console_Output;

_Console_Output = '';


/**
 *  Cleans the output string from previous messages
 *
 */
function clo() {   _Console_Output = ''; }


/**
 *  Prints a new string into the smart contract output channel
 *
 *  message : a string or a number
 *
 */
function print(message) { _Console_Output += message; }

/**
 *  prints a new line into the smart contract output channel
 * 
 *  message : a string or a number
 *
*/
function println(message) { _Console_Output += message + "\n"; }


/* Smart Contract State Management ********************************************************/

/**
 * List of data points that will be exported as persostent state
 *
 */
var _Contract_State;
_Contract_State = '';

/**
 * Saves the smart contract state for following execution
 *
 * obj : Object, which in this case will be the smart contract class
 *
 */
function _Save_Contract_State(obj) {
    var fields = {};
    for (var prop in obj) {
        fields[prop] = {
            type: typeof obj[prop],
            value: obj[prop]
        };
    }
    return JSON.stringify(fields);
}

/**
 * Extracts the global variables contract state to save it for future executions
 *
 */
function _Extract_Global_State() {
    var variables = [];
    for (var prop in this) { // 'this' refers to the global object when in the global scope
        var variable = {
            Name: prop,
            type: typeof this[prop],
            value: this[prop]
        };
        variables.push(variable);
    }
    var result = { Variables: variables };
    return JSON.stringify(result);
}

/**
 * Loads the smart contract state from previous executions
 *
 * obj : Object, which in this case will be the smart contract class
 *
 * jsonString : json formated string representing the contract state
 *
 */
function _Load_Contract_State(obj, jsonString) {
    if(jsonString == '') return;
    var parsedState = JSON.parse(jsonString);

    // Iterate through the properties in parsedState and update CRC_Contract
    for (var prop in parsedState) {
        if (parsedState[prop].type != "function")
        obj[prop] = parsedState[prop].value;
    }
}

/* Transaction Request Info ***************************************************************/

var CRC_Message = {        
                 ID : '',  // Transaction ID (sha256 hash)
               From : '',  // Sender wallet address
                 To : '',  // Smart contract address
          Timestamp : '',  // Transaction timestamp 
               Type : '',  // Type of Transaction
         Blockchain : '',  // Blockchain on which the transaction is being sent
          Signature : '',  // Transaction Signature (already validated)
            Payload : '',  // Transaction Payload (one of the methods of the contract class)
             Amount : 0.0, // amount of CIRX sent to the contract
           GasLimit : 0.0  // maximum amount of gas to execute the transaction
}; 



/* CRC-0024 Wallet Definition *************************************************************/

var CRC_Wallet = { 
           Address : '',   // Wallet Address
             Notes : '',   // generic text field
           Balance : 0.0,  // Balance of the current token
           Allowances: {}, // Allowances
         
/**
 * Loads the smart contract info from the physical wallet
 *
 * address : Wallet address
 *
 */ 
  OpenWallet: function (address)
    {
      this.Address = address;
      
      var w  = LoadWallet(address);
      
      if(w.Data !== '') {
          var data = JSON.parse(w.Data);
          if ('Notes' in data)      { this.Notes = data.Notes;          }
          if ('Balance' in data)    { this.Balance = data.Balance;      }
          if ('Allowances' in data) { this.Allowances = data.Allowances;}
      }

      return this;
    },

/**
 * Saves the smart contract the smart contract info in the physical wallet
 *
 */  
  CloseWallet: function() {
      // Create a new object to store the data
      var dataObject = {
           Address : this.Address,
             Notes : this.Notes,
           Balance : this.Balance,
        Allowances : this.Allowances
      };
      // Convert the data object to a JSON string
      var dataString = JSON.stringify(dataObject);
      
      // Use the SaveWallet function to save the updated wallet
      SaveWallet(this.Address, dataString);
    },
  
  
/**
 * Adds an allowance into the wallet allowances array. Creates a new allowance or updates the balance 
 * of an existing one
 *
 * allowanceAddress : address of the wallet granting the allowance
 *
 * Amount : Amount of the allowance
 *
 */  
  AddAllowance: function (allowanceAddress, Amount) {
      // Check if an allowance with the same address already exists
      if (this.Allowances.hasOwnProperty(allowanceAddress)) {
        // If an allowance with the same address exists, add the allowanceAmount to the existing allowance
        this.Allowances[allowanceAddress] += Amount;
      } else {
        // If no allowance with the same address exists, create a new allowance
        this.Allowances[allowanceAddress] = Amount;
      }

    },

  
/**
 * Spends an allowance into the wallet allowances array. Deletes the allowances that go to balance = 0
 *
 * allowanceAddress : address of the wallet granting the allowance
 *
 * amountToSpend : Amount that is being spent
 *
 */   
  SpendAllowance: function (allowanceAddress, amountToSpend) {
      // Check if an allowance with the specified address exists
      if (this.Allowances.hasOwnProperty(allowanceAddress)) {
        // Get the current allowance amount
        var currentAllowance = this.Allowances[allowanceAddress];

        // Calculate the new allowance amount after spending
        var newAllowance = currentAllowance - amountToSpend;

        // Check if the new allowance amount is greater than or equal to zero
        if (newAllowance >= 0) {
          // Update the allowance with the new amount
          this.Allowances[allowanceAddress] = newAllowance;
        } else {
          // The allowance would go below zero, so it cannot be spent
          // Remove the allowance from the Allowances object
          delete this.Allowances[allowanceAddress];
        }

        // Return true to indicate successful spending
        return true;
      } else {
        // The specified allowance address does not exist
        // Return false to indicate that the spending is not allowed
        return false;
      }
    },

  
/**
 * Deletes an existing allowance
 *
 * allowanceAddress : address of the wallet granting the allowance
 *
 */  
  DeleteAllowance: function (allowanceAddress) {
      // Check if an allowance with the specified address exists
      if (this.Allowances.hasOwnProperty(allowanceAddress)) {
        // Remove the allowance from the Allowances object
        delete this.Allowances[allowanceAddress];
        // Return true to indicate successful deletion
        return true;
      } else {
        // The specified allowance address does not exist
        // Return false to indicate that the allowance was not found and deleted
        return false;
      }
    }
  
};  


/**
 * Prints all the allowances present into a wallet
 *
 * wallet : Wallet Object
 *
 */
  function printAllowances(Wallet) {
    for (var allowanceAddress in Wallet.Allowances) {
      if (Wallet.Allowances.hasOwnProperty(allowanceAddress)) {
        var allowanceAmount = Wallet.Allowances[allowanceAddress];
        println(allowanceAddress + ', ' + allowanceAmount);
      }
    }
  }
