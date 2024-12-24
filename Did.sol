// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedIdentity {
    struct Identity {
        string name;
        string email;
        string verificationDocument;
        bool  isVerified;
        bool  isRevoked;
        address owner;
    }

    mapping(address => Identity) private identities;
    mapping(address => bool) private authorizedVerifiers;
    address private contractOwner;

    event IdentityRegistered(address indexed owner, string name, string email);
    event IdentityVerified(address indexed owner);
    event IdentityRevoked(address indexed owner);
    event VerifierAdded(address indexed verifier);
    event VerifierRemoved(address indexed verifier);

    modifier onlyManager(address _owner) {
        require(msg.sender == _owner, "Not the owners identity");
        _;
    }

    modifier onlyVerifier() {
        require(authorizedVerifiers[msg.sender], "Not an authorized verifier");
        _;
    }

    constructor() {
        contractOwner = msg.sender;
    }

    function registerIdentity(string memory _name, string memory _email, string memory _verificationDocument) public {
        require(identities[msg.sender].owner == address(0), "Identity already registered");
        
        identities[msg.sender] = Identity({
            name: _name,
            email: _email,
            verificationDocument: _verificationDocument,
            isVerified: false,
            isRevoked: false,
            owner: msg.sender
        });

        emit IdentityRegistered(msg.sender, _name, _email);
    }

    function verifyIdentity(address _identityOwner) public onlyVerifier {
        require(identities[_identityOwner].owner != address(0), "Identity not registered");
        require(!identities[_identityOwner].isRevoked, "Identity is revoked");

        identities[_identityOwner].isVerified = true;
        emit IdentityVerified(_identityOwner);
    }

    function revokeIdentity(address _identityOwner) public onlyVerifier {
        require(identities[_identityOwner].owner != address(0), "Identity not registered");
        
        identities[_identityOwner].isRevoked = true;
        emit IdentityRevoked(_identityOwner);
    }

    function getIdentity(address _identityOwner) public view returns (string memory, string memory, bool, bool) {
        require(identities[_identityOwner].owner != address(0), "Identity not registered");
        
        Identity memory identity = identities[_identityOwner];
        return (identity.name, identity.email, identity.isVerified, identity.isRevoked);
    }

    function addVerifier(address _verifier) public {
        require(msg.sender == contractOwner, "Only contract owner can add verifiers");
        authorizedVerifiers[_verifier] = true;
        emit VerifierAdded(_verifier);
    }

    function removeVerifier(address _verifier) public {
        require(msg.sender == contractOwner, "Only contract owner can remove verifiers");
        authorizedVerifiers[_verifier] = false;
        emit VerifierRemoved(_verifier);
    }
}
