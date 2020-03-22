pragma solidity >=0.4.17 <0.6.0;
contract Auction {
    
    struct Item {
        uint itemId; // id of the item
        uint[] itemTokens;  //tokens bid in favor of the item
    }
    
   //Structure to hold the details of a persons
    struct Person {
        uint remainingTokens; // tokens remaining with bidder
        uint personId; // it serves as tokenId as well
        address addr; //address of the bidder
    }
 
    mapping(address => Person) tokenDetails; //address to person 
    Person [4] bidders; //4 bidders
    
    Item [3] public items; 
    address[3] public winners; 
    address public beneficiary; //owner of the smart contract
    
    uint bidderCount = 0; //counter
    

    constructor() public payable{
        beneficiary = msg.sender;
        uint[] memory emptyArray;
        items[0] = Item({itemId:0, itemTokens:emptyArray});
        items[1] = Item({itemId:1, itemTokens:emptyArray});
        items[2] = Item({itemId:2, itemTokens:emptyArray});
    }
    

    function register() public payable{
        bidders[bidderCount].personId = bidderCount;
        bidders[bidderCount].addr = msg.sender;
        bidders[bidderCount].remainingTokens = 5; // only 5 tokens
        tokenDetails[msg.sender] = bidders[bidderCount];
        bidderCount++;
    }
    
    function bid(uint _itemId, uint _count) public payable {
       
        if (tokenDetails[msg.sender].remainingTokens < _count || _itemId > 2) revert();
 
        
        uint balance = tokenDetails[msg.sender].remainingTokens - _count;
        

        tokenDetails[msg.sender].remainingTokens = balance;
        bidders[tokenDetails[msg.sender].personId].remainingTokens = balance;//updating the same balance in bidders map.
        
        Item storage bidItem = items[_itemId];
        for(uint i = 0; i < _count; i++) {
            bidItem.itemTokens.push(tokenDetails[msg.sender].personId);    
        }
    }
    
    modifier onlyOwner {
        
        require(msg.sender == beneficiary);
        _;
       
    }
    
    
    function revealWinners() public onlyOwner {
        
        
        for (uint id = 0; id < 3; id++) {
            Item storage currentItem = items[id];
            if (currentItem.itemTokens.length != 0) {
            // generate random# from block number 
            uint randomIndex = (block.number / currentItem.itemTokens.length) % currentItem.itemTokens.length; 
            // Obtain the winning tokenId

            uint winnerId = currentItem.itemTokens[randomIndex];
                
            
            winners[id] = bidders[winnerId].addr;
                    
           
                
            }
        }
    } 

    function getPersonDetails(uint id) public view returns(uint, uint, address){
        return (bidders[id].remainingTokens, bidders[id].personId, bidders[id].addr);
    }

}
