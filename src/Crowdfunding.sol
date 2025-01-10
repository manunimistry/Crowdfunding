// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Crowdfunding {
    string public name;
    string public description;
    uint256 public goal;
    uint256 public deadline;
    address public owner;

    enum CampaignState { Active, Successful, Failed }

    CampaignState public state;

    struct Tier {
        string name;
        uint256 amount;
        uint256 backers;
    }

    //continur from 52:25, refund

    Tier[] public tiers;

    modifier onlyOwner(){
        require(msg.sender == owner, "Not the owner.");
        _;
    }

    modifier campaignOpen() {
        require(state == CampaignState.Active, "Campaign is not active.");
        _;
    }

    function checkAndUpdateCampaignState() internal {
        if(state == CampaignState.Active){
            if(block.timestamp >= deadline) {
                state = address(this).balance >= goal ? CampaignState.Successful : CampaignState.Failed;
            }else {
                state = address(this).balance >=goal ? CampaignState.Successful : CampaignState.Active;
            }
        }
    }

    constructor(string memory _name, string memory _descriprion, uint256 _goal, uint256 _durationInDays){
        name = _name;
        description = _descriprion;
        goal = _goal;
        deadline = block.timestamp + (_durationInDays * 1 days);
        owner = msg.sender;
        state = CampaignState.Active;
    }

    function fund(uint256 _tierIndex) public payable {
        require(msg.value > 0, "Must fund amount greater than 0.");
        require(block.timestamp < deadline, "Campaign has ended.");
        require(_tierIndex < tiers.length, "Invalid tier.");
        require(msg.value == tiers[_tierIndex].amount,"Incorrect amount");

        tiers[_tierIndex].backers++;

        checkAndUpdateCampaignState();

    }

    function addTier(string memory _name, uint256 _amount) public onlyOwner{
        
      require(_amount > 0, "Amount must be greater than 0");
      tiers.push(Tier(_name,_amount,0));
    }

    function removeTeir(uint256 _index) public onlyOwner {
        require(_index < tiers.length, "Tier does not exist.");
        tiers[_index] = tiers[tiers.length-1];
        tiers.pop();
    }

    function withdraw() public onlyOwner {
        checkAndUpdateCampaignState();
        require(state == CampaignState.Successful, "Campaign is not successful yet.");

        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdrraw.");

        payable(owner).transfer(balance);
    }

    function getContractBalance() public view returns(uint256){
        return address(this).balance;
    }
}