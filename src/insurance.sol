// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

contract CropInsurance is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    error CropInsurance_DonIDisImmutable();
    error CropInsurance_SendMoreEth();
    error CropInsurance_NotActive();
    error CropInsurance_InsufficientFunds();
    error CropInsurance_AlreadyClaimed();

    uint256 public constant MINIMUM_FEE = 0.001 ether;
    mapping(address => Policy) public policies;
    mapping(bytes32 => address) private requestIdToFarmer;

    struct Policy {
        uint256 coverageAmount;
        uint256 insuranceAmount;
        bool isActive;
        bool isClaimed;
        string location;
    }

    bytes32 public donID;
    uint64 private subscriptionId;
    uint32 private gasLimit;

    string private constant SOURCE =
        "const fetchWeatherData = async (city) => {const geoRes = await fetch(`https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(city)}&format=json&limit=1`);const { lat, lon } = (await geoRes.json())[0];const weatherRes = await fetch(`https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&hourly=precipitation&start=${new Date().toISOString().split('T')[0]}&timezone=auto`);const data = await weatherRes.json();let consecutiveRainHours = 0;for (const rain of data.hourly.precipitation) {consecutiveRainHours = rain >= 1 ? consecutiveRainHours + 1 : 0;if (consecutiveRainHours >= 30) return 'Damage';}return 'No Damage';};const city = args[0];return await fetchWeatherData(city);";

    event PolicyCreated(address indexed farmer, uint256 coverageAmount, uint256 insuranceAmount, string location);
    event ClaimRequested(address indexed farmer, bool claimed);
    event ClaimFulfilled(address indexed farmer, uint256 amount);
    event RequestFailed(bytes error);

    constructor(address router, bytes32 _donID, uint64 _subscriptionId, uint32 _gasLimit)
        FunctionsClient(router)
        ConfirmedOwner(msg.sender)
    {
        donID = _donID;
        subscriptionId = _subscriptionId;
        gasLimit = _gasLimit;
    }

    function setDonID(bytes32 newDonID) external onlyOwner {
        donID = newDonID;
    }

    function createPolicy(uint256 coverageAmount, string calldata location) external payable {
        if (msg.value < MINIMUM_FEE) {
            revert CropInsurance_SendMoreEth();
        }
        if (policies[msg.sender].isActive) {
            revert CropInsurance_AlreadyClaimed();
        }
        uint256 insuranceAmount = coverageAmount * 15 / 10;

        policies[msg.sender] = Policy({
            coverageAmount: coverageAmount,
            insuranceAmount: insuranceAmount,
            isActive: true,
            isClaimed: false,
            location: location
        });

        emit PolicyCreated(msg.sender, coverageAmount, insuranceAmount, location);
    }

    function requestClaim() external {
        Policy storage policy = policies[msg.sender];
        if (!policy.isActive) {
            revert CropInsurance_NotActive();
        }
        if (policy.isClaimed) {
            revert CropInsurance_AlreadyClaimed();
        }
        policy.isClaimed = true;

        string[] memory args = new string[](1);
        args[0] = policy.location;

        bytes32 requestId = _sendChainlinkRequest(args);

        requestIdToFarmer[requestId] = msg.sender;

        emit ClaimRequested(msg.sender, true);
    }

    function _sendChainlinkRequest(string[] memory args) internal returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequest(FunctionsRequest.Location.Inline, FunctionsRequest.CodeLanguage.JavaScript, SOURCE);
        if (args.length > 0) {
            req.setArgs(args);
        }
        requestId = _sendRequest(req.encodeCBOR(), subscriptionId, gasLimit, donID);
    }

    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        if (err.length > 0) {
            emit RequestFailed(err);
            return;
        }
        string memory result = string(response);
        address farmer = requestIdToFarmer[requestId];
        Policy storage policy = policies[farmer];
        if (!policy.isActive || policy.isClaimed) {
            return;
        }

        if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked("Damage"))) {
            policy.isActive = false;
            payable(farmer).transfer(policy.insuranceAmount);
            emit ClaimFulfilled(farmer, policy.insuranceAmount);
        } else {
            policy.isClaimed = false;
        }

        delete requestIdToFarmer[requestId];
    }
}
