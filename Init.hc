/******************************************************************************************
*
*         Circular Protocol
*         Smart Contract Endpoints Test
*         January 2024
*
*******************************************************************************************/

/**
 * Here you can test the different contract's endpoints
 *
 * IMPORTANT: this piece of code will be executed only in debugging mode and it will 
 * emulate the transaction payload. Transaction payloads have usually only one call,
 * but the testing mode will allow you to add extra code createing the desired testing 
 * conditions. It is important to undertand that in debugging mode, no effect will be
 * produced on the wallets. In testing mode (transaction on the sandbox blockchain)
 * the wallets will be affected by the transactions.
/*

/**

Issue JSON

{

  "Text" : " here the description of the issue",
  "Options" : [
    
       {"text":"describe option 1"},
       
       ...
       
       {"text":"describe option n"}
  ]

}



*/


/** Place here your endpoint testing code ******************************************************/

// called by default at the deployment
 CRC_Contract._constructor();




// creates a new Voting Issue
CRC_Contract.CreatingNewIssue('{"Text" : "Am I Good?", "Options" : [{"Text" : "YES"}, {"Text" : "MAYBE"}, {"Text" : "NO"}]}');


// Enable Voting Range
CRC_Contract.SetVotingRange(true, 4, 1000);

// sets a voting period of 10 days
// Understand that despite all nodes will use UTC timezone, votes casted at the very last few seconds could trigger inconsistencies
// in the state of the voting session. 
CRC_Contract.SetVotingPeriod(10);

//displays teh overall issue, Text + options
CRC_Contract.__GetIssue();

// opens the voting session
CRC_Contract.SetVotingOpen(true);

// submits soem votes
CRC_Contract.Vote(1);
CRC_Contract.Vote(1);
CRC_Contract.Vote(3);
CRC_Contract.Vote(2);
CRC_Contract.Vote(1);
CRC_Contract.Vote(2);

// closes the voting session
CRC_Contract.SetVotingOpen(false);

// extracts the first 2 winnind options 
CRC_Contract.__ExtractFirst(3);
