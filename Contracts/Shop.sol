pragma solidity ^0.4.24;

//FINAL COPY
contract Shop {
    
    address public contractOwner;
    uint public itemCount; 
    mapping (uint => Item) public items; 
    mapping (address => uint[]) public itemsOwned;
    mapping (address => uint) public balances; //Will represent the balances of a buyer
    
    //What an object item possesses
    struct Item {
        string name; 
        uint ID;
        uint price;
        address owner;
    }
    
    //Event declarations

    event listItemEvent(
        uint ID, 
        string name,
        uint price
    );
    
    event deleteItemEvent(
        uint ID 
    );
    
    event buyEvent(
        uint ID, 
        string name,
        uint price,
        address owner
    );
    
    event withdrawFundsEvent(
        address payee, 
        uint fundsWithdrawn
    );
    
    //Basic modifier indicating that an owner can only use certain things 
    modifier onlyOwner() {
        require(msg.sender == contractOwner);
        _;
    }
    
    constructor() public payable{
        contractOwner = msg.sender;
    }
  
    function listItem(string name, uint price) public onlyOwner {
       
        uint ID = itemCount; //Let the item ID be assigned to the amount of items 
        itemCount++;
        items[ID] = Item(name, ID, price, msg.sender); //Add the item to the mapping at index ID
        itemsOwned[msg.sender].push(ID); //Add new item in my own list 
        
        emit listItemEvent(ID, name, price); 
    }
    
    //Get rid of item bought
    //For simplification, this function does not 
    function deleteItem(uint ID) public {
        
        require(items[ID].owner != address(0)); //address at 0 represents a null address (extra check)
        require(msg.sender == items[ID].owner); //Make sure the item we're deleting is owned by the address caller
        delete items[ID]; 
        itemCount--; //Decrease item count 
     
        emit deleteItemEvent(ID);
    }
    
    function buyItem(uint ID) public payable {
        
        Item memory item = items[ID];
        
        
        require(items[ID].owner != address(0));
        require(item.owner != msg.sender); //Prevent buying own item
        require(msg.value == item.price); //Must send exact amount
        
        balances[item.owner] += msg.value; //Increment seller's balance
        itemsOwned[msg.sender].push(ID); //Add new item in my own list
        items[ID].owner = msg.sender; //Make the owner be the guy who sent the order
        
        emit buyEvent(ID, items[ID].name, items[ID].price, items[ID].owner);
    }
  
    //Withdraw function, whatever is in the balances 
    function withdrawFunds() public {
        
        address payee = msg.sender; 
        uint payment = balances[payee];
        
        //Check if payment is positive
        require(payment > 0);
        balances[payee] = 0;
        
        //Move funds
        require(payee.send(payment));
        
        emit withdrawFundsEvent(msg.sender, payment);
    }
    
    //Will show the IDs an address owns
    function getItemsOwned() public view returns (uint[]) {
        return (itemsOwned[msg.sender]);
    }
    
}