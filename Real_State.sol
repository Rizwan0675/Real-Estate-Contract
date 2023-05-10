// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;


// Data Structure for storing Land details
struct LandInfo{

        uint landId;
        string area;
        string city;
        string state;
        uint landPrice;
        bool isLandSold;
        bool isLandVerified;
        address propertyOwner;
        string propertyOwnerName;

}

// Data Structure for storing Buyer details
struct BuyerInfo{

        string buyerName;
        uint buyerAge;
        string city;
        uint cnic;
        string email;
        bool isBuyerVerified;      
}


// Data Structure for storing Seller details
struct SellerInfo{

        string sellerName;
        uint sellerAge;
        string city;
        uint sellerCNIC;
        string email;
        bool isSellerVerified;      
}


// Data Structure for storing Land Inspector details
struct LandInspector{

        address landInspectorId;
        string inspectorName;
        uint inspectorAge;
        string desgination;
                
}


contract RealState{

    // This will store the owner address, in this case Land Inspector.
    address public inspectorAddress;  
    uint inspectorId;

    // To keep track of total Lands Registered;
    uint public totalLands;
    // To keep track of total Sellers Registered;
    uint public totalSellers;

   // To keep track of total Buyers Registered;
    uint public totalBuyers;


    // Data Structure for storing Land details against Land Ids.
    mapping(uint => LandInfo) public Lands;

    // Data Structure for storing Land Inspector details against Land Inspecto Id.
    mapping(uint => LandInspector) public InspectorMapping;

    // Data Structure for storing Seller details against Seller Addresses.
    mapping(address => SellerInfo) public SellerMapping;

    // Data Structure for storing Buyer details againstBuyer Addresses.
    mapping(address => BuyerInfo) public BuyerMapping;

    // Below three mappings are used to store registration details of Seller,Buyer & Land.
    // If a seller or buyer is registered, the mapping will store true against their registered addresses.
    // mapping will store  true against landId of the registered land.
    mapping(address => bool) public CheckSellerRegistration;
    mapping(address => bool) public CheckBuyerRegistration;
    mapping(uint => bool) public CheckLandRegistration;


    // Events to log out particular details when status changes.
    event Users(string, string, address);
    event Land(string, uint);
    

    // the constructor below will initialize the land Inspector details during contract deployment.
    constructor(uint _inspectorId, string memory _name, uint _age, string memory _designation) {
        inspectorAddress = msg.sender;
        inspectorId = _inspectorId;
        InspectorMapping[_inspectorId] = LandInspector(inspectorAddress, _name, _age, _designation);
        emit Users("Inspector Registered: ", _name, inspectorAddress);
    }

    
    // This modifier, if applied on functions will restrict the functions to be executed only by Land Inspector.
    modifier onlyInspector(){
        require(inspectorAddress == msg.sender, "You are not authorized to execute this transaction");
        _;
    }

    
    // This function will be used to Register Seller.
    function registerSeller
    (
        address sellerId,
        string memory _sellerName,
        uint _sellerAge,
        string memory _city,
        uint _sellerCnic,
        string memory _email
    )
    public
    {
        // These conditions will be checked first, before registering Seller.
        require(sellerId != inspectorAddress, "Inspector is registered with this Address");
        require(CheckSellerRegistration[sellerId] == false,"Seller already Exists with the same address");
        require(CheckBuyerRegistration[sellerId] == false,"Buyer already Exists with the same address");
        require(BuyerMapping[sellerId].cnic != SellerMapping[sellerId].sellerCNIC, "Buyer with same CNIC exists");
        require(SellerMapping[sellerId].sellerCNIC != _sellerCnic, "Seller with same CNIC exists");

        
        SellerMapping[sellerId].sellerName = _sellerName;
        SellerMapping[sellerId].sellerAge = _sellerAge;
        SellerMapping[sellerId].city = _city;
        SellerMapping[sellerId].sellerCNIC = _sellerCnic;
        SellerMapping[sellerId].email = _email;
        CheckSellerRegistration[sellerId] = true;

        totalSellers += 1;
        emit Users("Seller Registered: ",_sellerName, sellerId);

    }

    // This function will update the info of the seller if required.
    function updateSeller
    (
        string memory _sellerName,
        uint _sellerAge,
        string memory city,
        uint _sellerCNIC,
        string memory email
    )
    public
    {
        require(CheckSellerRegistration[msg.sender] == true,"Seller is not Registered.");
        require(SellerMapping[msg.sender].sellerCNIC != 0, "Seller is not registered");
        SellerMapping[msg.sender] = SellerInfo(_sellerName, _sellerAge, city, _sellerCNIC, email, false);

        emit Users("Seller Updated: ", _sellerName, msg.sender);
        
    }


    // This function will Register Buyers in the Contract.
    function registerBuyer
    (
        address buyerId,
        string memory _buyerName,
        uint _buyerAge,
        string memory _city,
        uint _buyerCnic,
        string memory _email
    )
    public
    {
        // These conditions will be checked first, before registering Buyer.
        require(buyerId != inspectorAddress, "Inspector is registered with this Address");
        require(CheckBuyerRegistration[buyerId] == false, "Buyer is already registered with the same address");
        require(CheckSellerRegistration[buyerId] == false,"Seller already Exists with the same address");
        require(BuyerMapping[buyerId].cnic != SellerMapping[buyerId].sellerCNIC, "Seller with same CNIC exists");
        require(BuyerMapping[buyerId].cnic != _buyerCnic, "Buyer with same CNIC exists");


        BuyerMapping[buyerId].buyerName = _buyerName;
        BuyerMapping[buyerId].buyerAge = _buyerAge;
        BuyerMapping[buyerId].city = _city;
        BuyerMapping[buyerId].cnic = _buyerCnic;
        BuyerMapping[buyerId].email = _email;
        CheckBuyerRegistration[buyerId] = true;

        totalBuyers += 1;
        emit Users("Buyer Registered: ",_buyerName, buyerId);

    }


    // This function will update the info of the buyer if required.
    function updateBuyer
    (
        string memory _buyerName,
        uint _buyerAge,
        string memory city,
        uint _buyerCNIC,
        string memory email
    )
    public
    {
        require(CheckBuyerRegistration[msg.sender] == true,"Buyer is not Registered.");
        require(BuyerMapping[msg.sender].cnic != 0, "Buyer is not registered");
        BuyerMapping[msg.sender] = BuyerInfo(_buyerName, _buyerAge, city, _buyerCNIC, email, false);
        emit Users("Buyer Updated: ", _buyerName, msg.sender);
    }


    // Function used by Verified Seller to register Land
    function registerLand
    (
        uint landId,
        string memory _area,
        string memory _city,
        string memory _state,
        uint _landPrice
    )
    public
    {
        require(CheckSellerRegistration[msg.sender] == true, "Seller is not registered, so can't register land");
        require(SellerMapping[msg.sender].isSellerVerified == true, "Seller is not verified by the land inspector");
        require(CheckLandRegistration[landId] == false, "Land is already Registered with the same id");
        require(msg.sender != inspectorAddress, "Land can only be registered by seller");

        
        Lands[landId].landId = landId;
        Lands[landId].area = _area;
        Lands[landId].city = _city;
        Lands[landId].state= _state;
        Lands[landId].landPrice = _landPrice;
        // lands[landId].propertyPID = _propertyPId;
        Lands[landId].propertyOwner = msg.sender;
        Lands[landId].propertyOwnerName = SellerMapping[msg.sender].sellerName;
        CheckLandRegistration[landId] = true;

        totalLands += 1;
        emit Land("Land Registered: ", landId);

    }


    // Function that is used by inspector to change Seller to Buyer
    function changeSellertoBuyer
    (
        address _sellerAddress
    )
    public
    onlyInspector
    {
        require(CheckSellerRegistration[_sellerAddress] == true, "Seller is not registered with the provided Address");
        require(SellerMapping[_sellerAddress].isSellerVerified == true, "Seller is not verified by the Land Inspector");

        BuyerMapping[_sellerAddress].buyerName = SellerMapping[_sellerAddress].sellerName;
        BuyerMapping[_sellerAddress].buyerAge = SellerMapping[_sellerAddress].sellerAge;
        BuyerMapping[_sellerAddress].city = SellerMapping[_sellerAddress].city;
        BuyerMapping[_sellerAddress].cnic = SellerMapping[_sellerAddress].sellerCNIC;
        BuyerMapping[_sellerAddress].email = SellerMapping[_sellerAddress].email;
        BuyerMapping[_sellerAddress].isBuyerVerified = false;
        CheckBuyerRegistration[_sellerAddress] = true;
        CheckSellerRegistration[_sellerAddress] = false;
        totalSellers -= 1;
        totalBuyers += 1;

        delete SellerMapping[_sellerAddress];
    }



    // Function that is used by inspector to change Buyer to Seller
    function changeBuyertoSeller
    (
        address _buyerAddress
    )
    public
    onlyInspector
    {
        require(CheckBuyerRegistration[_buyerAddress] == true, "Buyer is not registered with the provided Address");
        require(BuyerMapping[_buyerAddress].isBuyerVerified == true, "Buyer is not verified by the Land Inspector");

        SellerMapping[_buyerAddress].sellerName = BuyerMapping[_buyerAddress].buyerName;
        SellerMapping[_buyerAddress].sellerAge = BuyerMapping[_buyerAddress].buyerAge;
        SellerMapping[_buyerAddress].city = BuyerMapping[_buyerAddress].city;
        SellerMapping[_buyerAddress].sellerCNIC = BuyerMapping[_buyerAddress].cnic;
        SellerMapping[_buyerAddress].email = BuyerMapping[_buyerAddress].email;
        SellerMapping[_buyerAddress].isSellerVerified = false;
        CheckBuyerRegistration[_buyerAddress] = false;
        CheckSellerRegistration[_buyerAddress] = true;
        totalSellers += 1;
        totalBuyers -= 1;

        delete BuyerMapping[_buyerAddress];
    }


    // Returns LandInfo by using the landId of the requested Land.
    function getLandById
    (
        uint landId
    )
    public
    view 
    returns
    (
        uint,
        string memory,
        string memory,
        string memory,
        uint,
        address,
        string memory
    )
    {

        require(Lands[landId].landId != 0, "Land with given ID does not exist");
        return
        (
            Lands[landId].landId,
            Lands[landId].area,
            Lands[landId].city,
            Lands[landId].state,
            Lands[landId].landPrice,
            Lands[landId].propertyOwner,
            Lands[landId].propertyOwnerName
        );
    }


    // This function will be used by Land inspector to verify the seller.
    function verifySeller
    (
        address _sellerAddress
    )
    public
    onlyInspector
    {
        require(CheckSellerRegistration[_sellerAddress] == true, "Seller with the provided Address does not Exist");
        require(SellerMapping[_sellerAddress].isSellerVerified == false, "Seller swith provided address is already verified");
        require(CheckBuyerRegistration[_sellerAddress] == false, "Buyer with provided address already exist.");
        SellerMapping[_sellerAddress].isSellerVerified = true;

        emit Users("Seller gets Verified by Land Inspector with: ", SellerMapping[_sellerAddress].sellerName, _sellerAddress);

    }


    // This function will be used by Land inspector to verify the buyer.
    function verifyBuyer
    (
        address _buyerAddress
    )
    public
    onlyInspector
    {
        require(CheckBuyerRegistration[_buyerAddress] == true, "Buyer with the provided Address does not Exist");
        require(CheckSellerRegistration[_buyerAddress] == false,"Seller is registered with this Address");
        require(SellerMapping[_buyerAddress].sellerCNIC == 0, "This is Seller Address");
        require(BuyerMapping[_buyerAddress].isBuyerVerified == false, "Buyer with provided address is already verified");
        BuyerMapping[_buyerAddress].isBuyerVerified = true;

        emit Users("Seller gets Verified by Land Inspector with: ", BuyerMapping[_buyerAddress].buyerName, _buyerAddress);

    }


    // This function will be used by Land inspector to verify the Land.
    function verifyLand
    (
        uint _landId
    )
    public
    onlyInspector
    {
        require(CheckLandRegistration[_landId] == true, "Land does not exits with the provided id");
        require(Lands[_landId].isLandVerified == false, "Land is already verified");
        Lands[_landId].isLandVerified = true;

        emit Land("Land is verified by landInspector with id: ", _landId);

    }


    // To check if a particular Seller is Verified or not, will return true in case of verified and false otherwise.
    function checkIsSeller
    (
        address _sellerAddress
    )
    public
    view 
    returns(bool)
    {
        return SellerMapping[_sellerAddress].isSellerVerified;
    }

    // To check if a particular Buyer is Verified or not, will return true in case of verified and false otherwise.
    function checkIsBuyer
    (
        address _buyerAddress
    )
    public
    view
    returns(bool){
        return BuyerMapping[_buyerAddress].isBuyerVerified;
    }

    // To check if a particular Land is Verified or not, will return true in case of verified and false otherwise.
    function checkIsland
    (
        uint _landId
    )
    public
    view 
    returns(bool)
    {
        return Lands[_landId].isLandVerified;
    }

    // To check the owner of a particular land, will return the address of the owner.
    function landOwner
    (
        uint _landId
    )
    public
    view
    returns
    (
        address,
        string memory
    )
    {
        return (Lands[_landId].propertyOwner, Lands[_landId].propertyOwnerName);
    }

    // To check Land Inspector of the Contract.
    function inspector()
    public
    view
    returns
    (
        address,
        string memory
    )
    {
        return (InspectorMapping[inspectorId].landInspectorId, InspectorMapping[1].inspectorName);
    }



    // this functons will be use by buyer to buy land and tranfer amount. 
    // As soon as amount is transfered to the seller account, Land ownership will be transferred to the Buyer.
    function buyLand
    (
        uint _landId, 
        address payable _to
    )
    public
    payable
    {
        require(BuyerMapping[msg.sender].isBuyerVerified == true, "Buyer not verified by land inspector");
        require(Lands[_landId].isLandSold == false, "Land already sold");
        require(SellerMapping[Lands[_landId].propertyOwner].isSellerVerified == true, "Seller not verified by land inspector");
        require(Lands[_landId].isLandVerified == true, "Land is not Verified.");
        require(msg.value == Lands[_landId].landPrice, "Land Price is not matching with the sent amount");
        _to.transfer(msg.value);

        Lands[_landId].isLandSold = true;
        Lands[_landId].propertyOwner = msg.sender;
        Lands[_landId].propertyOwnerName = BuyerMapping[msg.sender].buyerName;

        emit Users("Ownership is transferred to", BuyerMapping[msg.sender].buyerName, msg.sender);


    }


    // This function will be used by the seller to transfer ownership to another seller.
    function transferLand
    (
        uint landId,
        address _address
    )
    public
    {
        require(SellerMapping[Lands[landId].propertyOwner].isSellerVerified == true, "Seller not verified by land inspector");
        require(Lands[landId].isLandSold == false, "Land is sold, so can't transfer to another seller");
        require(Lands[landId].propertyOwner == msg.sender, "Only Land Owner is allowed to transfer Ownership");
        Lands[landId].propertyOwner = _address;
        Lands[landId].propertyOwnerName = SellerMapping[_address].sellerName;

        emit Users("Ownership is transferred to", SellerMapping[_address].sellerName, _address);
    }

}