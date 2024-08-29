# Internal audit 
The review has been performed based on the contract code in the following repository:<br>
`https://github.com/abhishekb740/Valory-Assignment` <br>
commit: 112c7acef7cc8d78bcc8a10c2ad98ccdb88c572a <br>

# Overall assessment.
The code does not contain any obvious bugs and corresponds to the ideas of the task.

# Auditor comments and good practices.
1. There is no change of ownership function in MiniTreasury. Possibly outside the scope of the task.
2. There is a general problem with token allowing/disabling, that as described in the function, the restriction only affects withdrawals. <br>
Thus, this creates the possibility of locking tokens in a contract (simple example: deposit to disabled token). <br>
In general, I do not expect all cases to be solved in this test task. <br>
It is enough to add a check for a whitelisting on deposit(). <br>
3. This is beyond the scope of the tasks, but it is necessary to add clarification that https://github.com/d-xo/weird-erc20 out of scope allowed ERC-20 implementation.

## ERC721 logic (not KISS as possible)
```
1. In my opinion, an array is not required.
[msg.sender][token][id] - Uniquely indicate any combination of the original owner, token address, id (for ERC721)
Arrays should only be used if there are no other options. In any cases, priority should be given to the design using O(1) operation
2. Rewriting callback as onERC721Received() and put some logic is a bad idea. 
I know this is considered a basic pattern in NEAR, but due to the potential for bugs, it is best avoided in Solidity/EVM.
```



