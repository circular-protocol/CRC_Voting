/******************************************************************************************
*
*         Circular Protocol
*         CRC Voting Smart Contract Template  
*         January 2024
*
*******************************************************************************************/


var CRC_Contract = {

           _Name : "CRC_Voting", // Token Name. It must match the project name in the settings 
         _Symbol : "VTG",        // Asset Tiker.It must match the one in the settings 
          _Owner : "Owner Address here", // Asset Owner Address
  
        _IssueID : '',           // Voting Issue ID      
          _Issue : '',           // IssueJSON file
  
     _TotalVotes : 0,            // Total Votes received
        _Options : 0,            // Number of Options to vote on
     _VotingOpen : false,        // tells us if a voting is currently opened.
  
    _VotingRange : false,        // Enable/disable voting range min votes/max votes
       _MinVotes : 3,            // minimum votes required to complete
       _MaxVotes : 100,          // maximum votes required to close votng
  
    _ClosingDate : 0,            // Closing date for the voting session
  
/** 
 * Contract Constructor. It will be executed only once, when the contract is deployed.
 *
 */
    _constructor: function() {
      
      this._IssueID = SHA256('0');
      println('Initialized IssueID : ' + this._IssueID);
      
    },
  
  
/** 
 * Creates a new Voting Issue
 *
 * @param jsonText : JSON formated issue file
 *  
 * FORMAT => { "Text" : "Iddue description", "Options" : [ {"text":"description option 1"}, ... ] }
 *
 */  
    CreatingNewIssue: function (jsonText)
    {
      
      // ensures that the owner is the one calling the function and there is no opened session
      if(msg.From == this._Owner && !this._VotingOpen){
      
       // creates a new Issue ID 
       this._IssueID = SHA256(this._IssueID);
        
       //reset the description 
       this._Issue = stringToHex(jsonText);

       // reset the initial number of votes  
       this._TotalVotes = 0,
         
       this._VotingRange = false;
       this._MinVotes = 3;
       this._MaxVotes = 100;
        
       this.ClosingDate = 0;
        
       println('Created New Voting Issue, ID : ' + this._IssueID);
       return true; 
        
      }
      println('ERROR: Voting Session open.');
      return false;
    },



/** 
 * Returns the current Issue Text and voting options
 *
 */  
    __GetIssue: function () {
      
        var Issue = JSON.parse(hexToString(this._Issue));
      
        // Assuming this._Issue contains the JSON string similar to the 'issue' variable provided
        println('Issue : ' + Issue.Text); // Print the main issue text

        // Parse the existing options object to access the Options array
        var options = Issue.Options;

        // Iterate over the Options array and print each option
        options.forEach(function(option, index) {
            // Access each option's Text and print its details
            println('Option ' + (index + 1) + ' : ' + option.Text);
        });

        return true; // Indicates success
    },

  
 
/** 
 * Opens/Closes the voting session
 *
 * @param open : opening/closing flag true = open, false = close 
 *
 */  
    SetVotingOpen: function (open) {
        
      // Verify the identity of the owner and if there is a voting session open
      if (msg.From == this._Owner){
        
        this._VotingOpen = open;
        
        if(open)
        {
          this._TotalVotes = 0;
        }
        
        if(open) println('SUCCESS : Vote Session : Open'); 
        else     println('SUCCESS : Vote Session : Closed'); 
        return true;
      
      }
      println('ERROR: Un-authorized Access.');
      return false;
        
    },
  
      
/** 
 * Enables/Disables/sets voting range
 *
 * @param Enable : Enables/Disables Range true = Enabled, false = Disabled 
 *
 * @param min : minimum number of votes to consider the voting valid 
 *
 * @param max : maximum number of votes accepted
 *
 */  
    SetVotingRange: function (Enable, min, max) {
        
      // Verify the identity of the owner and if there is a voting session open
      if (msg.From == this._Owner && !this._VotingOpen){
        
         this._VotingRange = Enable;
         this._MinVotes = min;
         this._MaxVotes = max;
        
         if(Enable) println('SUCCESS : Vote Range : Enabled'); 
         else       println('SUCCESS : Vote Range : Disabled'); 
         return true;
      
      }
      println('ERROR: Un-authorized Access.');
      return false;
        
    },      

  
/** 
 * Sets a deadline for the voting session
 *
 * @param Enable : Enables/Disables Range true = Enabled, false = Disabled 
 *
 * @param min : minimum number of votes to consider the voting valid 
 *
 * @param max : maximum number of votes accepted
 *
 */  
  
    SetVotingPeriod: function (days) {
        // Verify the identity of the owner and if there is a voting session open
        if (msg.From == this._Owner && !this._VotingOpen){
            // Get the current date in UTC
            var currentDate = new Date(); // This gets the current date and time in the node's local timezone

            // Convert the current date to UTC by adjusting to UTC hours
            var utcDate = new Date(Date.UTC(currentDate.getUTCFullYear(), 
                                            currentDate.getUTCMonth(), 
                                            currentDate.getUTCDate(), 
                                            currentDate.getUTCHours(), 
                                            currentDate.getUTCMinutes(), 
                                            currentDate.getUTCSeconds()));

            // Add the specified number of days to the UTC date
            utcDate.setUTCDate(utcDate.getUTCDate() + days);

            // Store the voting deadline as a UTC timestamp
            this._ClosingDate = utcDate.getTime(); // Storing as a timestamp ensures timezone is not a factor

            println('Voting period set. Voting ends on: ' + utcDate.toUTCString()); // Displays the deadline in UTC
            return true;
        }
        println('ERROR: Un-authorized Access or Voting Session already open.');
        return false;
    },
  
  
  
  
/**
 * Casts a vote for a specified voting issue option
 *
 * @param optionIndex : option you wish to vote [1 to n]
 *
 */
    Vote: function (optionIndex) {

        // Verify if there is a voting session open
        if (this._VotingOpen) {

            // verifies if the voting session is expired
            if (this._ClosingDate!= 0 && Date.now() > this._ClosingDate){
              this._VotingOpen =  false;
               println('ERROR: Voting Session Expired.');
               return false;
            }
              
            // Parse the existing options object
            var issueObj = JSON.parse(hexToString(this._Issue));


            // Extracts teh Options array
            var options = issueObj.Options; 

            // decreased by 1 to go in range [0 - length-1]
            optionIndex--;

            // Check if the option index is within the range of available options
            if (optionIndex >= 0 && optionIndex < options.length) {

                // Attempt to open wallet and verify single vote
                var User = Object.create(CRC_Wallet); // Assuming CRC_Wallet is previously defined
                User.OpenWallet(msg.From); // Assuming msg.From contains the user identifier

                // Check if the user has already voted
                if (User.hasOwnProperty('Notes') && User.Notes == this._IssueID) {
                    println('ERROR: Vote Already Casted.');
                    return false;
                }

                // Mark this issue as voted on in the user's wallet
                User.Notes = this._IssueID;
                User.CloseWallet(); // Save the changes to the wallet

                // Add or increment the Votes field for the specified option
                if (!options[optionIndex].hasOwnProperty('Votes')) {
                    options[optionIndex]['Votes'] = 1;
                } else {
                    options[optionIndex]['Votes'] += 1;
                }

                // Increment the total votes count
                this._TotalVotes ++;

                // if the voting range is enabled and the maximum number of votes has been reached 
                if(this._VotingRange && this._TotalVotes >= this._MaxVotes)
                {
                   // closes the voting automatically
                   this._VotingOpen = false;
                }

                // Re-serialize the modified issue object and update storage
                this._Issue = stringToHex(JSON.stringify(issueObj));

                println('SUCCESS: Vote Casted by: ' + msg.From);
                return true;
            } else {
                println('ERROR: Option does not exist.');
                return false;
            }
        } else {
            println('ERROR: Voting Session not open.');
            return false;
        }
    },

  

/**
 * Extracts and displays the first `number` of winning options in decreasing order of votes.
 *
 * @param {number} number - The number of top options to extract.
 *
 */
    __ExtractFirst: function (number) {
      
            // verifies if the voting session is expired
            if (this._ClosingDate!= '' && Date.now() > this._ClosingDate){
              this._VotingOpen =  false;
            }
      
            // informs if the session is open or closed
            if(this._VotingOpen)  println('Voting Session : OPEN'); 
            else                  println('Voting Session : CLOSED');
      
            // provides a result if the session is closed and there is a range. 
            if(!this._VotingOpen && this._VotingRange)
            {
               if(this._TotalVotes < this._MinVotes)  println('Final Outcome : INVALID');
               else                                   println('Final Outcome : VALID');

            }
      
            // Parse the existing issue object, which includes the options array
            var issueObj = JSON.parse(hexToString(this._Issue));

            // Directly accessing the Options array
            var optionsArray = issueObj.Options; 

            // Ensure each option has a 'Votes' field; initialize with 0 if not present
            optionsArray.forEach(function(option) {
                if (!option.hasOwnProperty('Votes')) {
                    option.Votes = 0; // Initialize 'Votes' if not present
                }
            });

            // Sort the array based on votes in decreasing order
            optionsArray.sort(function(a, b) {
                return b.Votes - a.Votes; // Sorts in descending order
            });

            // Extract the first `number` of options
            var topOptions = optionsArray.slice(0, number);

            // Display the top options
            topOptions.forEach(function(option, index) {
                println('Option ' + (index + 1) + ': ' + option.Text + ' with ' + option.Votes + '/' + this._TotalVotes + ' votes');
            }, this); // Use 'this' inside forEach to refer to the outer context

            return true; // Indicates success
        },

    };
