pragma solidity ^0.5.11;
contract TaxiBusiness {
    address public Manager; 
    address payable TaxiDriver; 
    uint DriverSalary;      //TaxiDriver salary
    address payable ProposeDriveradd;    //Propose Driver by Manager 
    uint Proposesalaryadd;   //Propose Driver salary by Manager
    address payable CarDealer; 
    uint Fixedexpenses;    
    uint carvalid;
    uint taxisalary; 
    uint Participationfee;    //Taxi Business participation fee.
    uint Participantslen;     //Taxi Business participation lenght.
    uint totaldrivervote;         //Total votes used for the drive.
    uint Contractbalance;    
    uint Releasetime;  //The period held for the salary of the taxi driver.
    uint CarExpensesTime; //The period held for Car Expenses.
    uint Driveraccount;   //The money in the driver's account.
    uint dividendtime;    //The period held for dividend.
    uint dividendpay;   //Dividend per person.
    
    struct Participant {        //Participant Specs.
        uint MemberValid;   //for isMember or Not Check
        uint approvote;     //Purchasecar Vote
        uint approvesellvote;   //Repurchasecar Vote
        uint drivervote;    //TaxiDriver Vote
        uint dividend;   //Participant balance
    }
    
    mapping(address => Participant) public Participantarray;     //Participant definition
    address[] Participantadresses;      //Participant adress array definition
    
    struct ProposedCar{     //ProposedCar Specs.
        uint32 carID;
        uint price;
        uint offerValidTime;
        uint approvalState;
    }
    mapping(address => ProposedCar) proposedCar;  //ProposedCar definition
    mapping(address => ProposedCar) proposedRepurchase;   //ReProposedCar definition
    
    
    modifier onlyManager(){     
        require(msg.sender == Manager,"The user is not a Manager.");
        _;
    }
    modifier onlyCarDealer(){
        require(msg.sender == CarDealer,"The user is not a CarDealer.");
        _;
    }
    modifier onlyTaxiDriver(){
        require(msg.sender == TaxiDriver,"The user is not a TaxiDriver.");
        _;
    }
    constructor() public {
        Manager=msg.sender;
        DriverSalary= 0 ether;
        Fixedexpenses=10 ether;
        taxisalary=0 ether; 
        Participationfee=100 ether;
        Participantslen= 0; 
        totaldrivervote =0; 
        Contractbalance=0 ether;
        Releasetime=0;
        CarExpensesTime=0;
        Driveraccount=0 ether;
        dividendtime=0; 
        carvalid=0;
    } 
    function Join() public payable {
        require(Participantslen < 9,"Taxi Business Participant limit exceeded.");  
        require(msg.value >= 100 ether,"The Participant does not have 100 ethers.");
        require(Participantarray[msg.sender].MemberValid!=1,"You already a Participant.");
        Contractbalance+=100 ether;         
        Participantarray[msg.sender]=Participant(1,0,0,0,0);
        Participantadresses.push(msg.sender);
        Participantslen+=1;
    }
    function SetCarDealer(address payable _CarDealer) public onlyManager {
       CarDealer = _CarDealer;
    } 
    function CarProposeToBusiness( 
        uint32 _carID, 
        uint _Price, 
        uint _offerValidTime
    ) public onlyCarDealer {
        proposedCar[CarDealer].carID = _carID;
        proposedCar[CarDealer].price = _Price;
        proposedCar[CarDealer].offerValidTime = _offerValidTime;
        proposedCar[CarDealer].approvalState = 0;
    }
    function ApprovePurchaseCar() public {
        require(Participantarray[msg.sender].MemberValid==1,"The user is not a Participant.");
        require(Participantarray[msg.sender].approvote!=1,"The vote was cast before.");
        proposedCar[CarDealer].approvalState+=1;
        Participantarray[msg.sender].approvote=1;
    } 
    function PurchaseCar() public onlyManager{ 
        require(block.timestamp < proposedCar[CarDealer].offerValidTime,"ProposedCar has expired.");
        require(proposedCar[CarDealer].approvalState > Participantslen/2,"The number of votes was not accepted by at least 51%.For Purchasecar.");
        CarDealer.transfer(proposedCar[CarDealer].price); 
        Contractbalance-=proposedCar[CarDealer].price;
        proposedCar[CarDealer].approvalState=0;
        carvalid=1;
        
    } 
    function RepurchaseCarPropose(
        uint32 _ownedcarID, 
        uint _Price, 
        uint _offerValidTime
    ) public onlyCarDealer {
        proposedRepurchase[CarDealer].carID = _ownedcarID;
        proposedRepurchase[CarDealer].price = _Price;
        proposedRepurchase[CarDealer].offerValidTime = _offerValidTime;
        proposedRepurchase[CarDealer].approvalState = 0;
    }
    function ApproveSellProposal() public {
        require(Participantarray[msg.sender].MemberValid==1,"The user is not a Participant.");
        require(Participantarray[msg.sender].approvesellvote!=1,"The vote was cast before.");
        proposedRepurchase[CarDealer].approvalState+=1;
        Participantarray[msg.sender].approvesellvote=1;
    }
    function Repurchasecar() public onlyCarDealer {
        require(block.timestamp < proposedRepurchase[CarDealer].offerValidTime,"Proposed Repurchasecar has expired.");
        require(proposedRepurchase[CarDealer].approvalState > Participantslen/2,"The number of votes was not accepted by at least 51%.For Repurchasecar.");
        CarDealer.transfer(proposedRepurchase[CarDealer].price);
        Contractbalance-=proposedRepurchase[CarDealer].price;
        carvalid=0;
       
    }
    function ProposeDriver(address payable _TaxiDriver,uint _salary) public onlyManager {
        ProposeDriveradd = _TaxiDriver;
        Proposesalaryadd = _salary;
    }
    function ApproveDriver() public  {
        require(Participantarray[msg.sender].MemberValid==1,"The user is not a Participant.");
        require(Participantarray[msg.sender].drivervote!=1,"The vote was cast before.");
        totaldrivervote+=1;
        Participantarray[msg.sender].drivervote=1;
    }
    function SetDriver() public onlyManager {
        require(totaldrivervote>Participantslen/2,
        "The number of votes was not accepted by at least 51%.For TaxiDriver.");
        TaxiDriver = ProposeDriveradd;
        DriverSalary = Proposesalaryadd;
        totaldrivervote=0;
        for (uint i=0; i<Participantslen; i++) {
            Participantarray[Participantadresses[i]].drivervote = 0;
        }
    } 
    function FireDriver() public onlyManager { 
        TaxiDriver.transfer(taxisalary);
        TaxiDriver=address(0);
        DriverSalary=0;
    } 
    function GetCharge() public payable{
        Contractbalance+=msg.value;
    } 
    function ReleaseSalary() public onlyManager  {
        require(block.timestamp > Releasetime,"The driver's salary has not yet expired for a month.");
        Releasetime = block.timestamp + 2629743;
        Driveraccount+=taxisalary;
        Contractbalance-=taxisalary;
    } 
    function GetSalary() public onlyTaxiDriver{ 
        require(Driveraccount != 0,"There is no money in the driver account.");
        TaxiDriver.transfer(Driveraccount); 
        Driveraccount=0; 
    } 
    function CarExpenses() public onlyManager{
        require(block.timestamp > CarExpensesTime,"It hasn't been 6 months since the last CarExpenses were sent.");
        CarExpensesTime = block.timestamp+15778463;          
        CarDealer.transfer(Fixedexpenses);
        Contractbalance-=Fixedexpenses;
    }
    function PayDividend() public onlyManager{ 
        require(block.timestamp > dividendtime,"It hasn't been 6 months since the last dividend was transfering to the balances.");
        dividendtime = block.timestamp + 15778463;   
        dividendpay= Contractbalance/Participantslen;
        for (uint256 i=0; i<Participantslen; i++) {
            Participantarray[Participantadresses[i]].dividend += dividendpay;
            Contractbalance-=dividendpay;
        }
    }
    function GetDividend() public payable {
        require(Participantarray[msg.sender].MemberValid==1,"The user is not a Participant.");
        require(Participantarray[msg.sender].dividend!= 0,"There is no money.");
        Participantarray[msg.sender].dividend=0;
        /*msg.sender.transfer(Participantarray[msg.sender].dividend); if activate this line getdividend will run, and giving error. I dont now. =)*/ 
        
    }
    function() external { 
    }
}
