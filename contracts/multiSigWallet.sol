// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSigWallet {
    address public owner;
    address[] public signers;
    uint256 public requiredSignatures;
    mapping(address => bool) public isSigner;
    mapping(uint256 => Transaction) public transactions;
    uint256 public transactionCount;

    struct Transaction {
        address to;
        uint256 value;
        uint256 numConfirmations;
        bool executed;
    }

    struct Data {
        address to;
        uint256 amount;
    }

    bytes32 public constant DATA_TYPEHASH =
        keccak256("Data(address to,uint256 amount)");
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 public DOMAIN_SEPARATOR;

    event Deposit(address sender, uint256 amount);
    event SubmitTransaction(
        address owner,
        uint256 txIndex,
        address to,
        uint256 value,
        bytes data
    );
    event ConfirmTransaction(address owner, uint256 txIndex);
    event ExecuteTransaction(address owner, address signer, uint256 amount);

    modifier onlySigner() {
        require(isSigner[msg.sender], "Not a signer");
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Not a signer");
        _;
    }

    constructor(
        address _owner,
        address[] memory _signers,
        uint256 _requiredSignatures
    ) {
        require(_signers.length > 0, "Signers required");
        require(
            _requiredSignatures > 0 && _requiredSignatures <= _signers.length,
            "Invalid number of required signatures"
        );

        for (uint256 i = 0; i < _signers.length; i++) {
            address signer = _signers[i];
            require(signer != address(0), "Invalid signer");
            require(!isSigner[signer], "Signer not unique");

            isSigner[signer] = true;
            signers.push(signer);
        }

        requiredSignatures = _requiredSignatures;
        owner = _owner;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes("MyDApp")),
                keccak256(bytes("1")),
                11155111,
                address(this)
            )
        );
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function addSigners(
        address[] memory _signers,
        uint256 newRequiredSignatures
    ) external {
        require(
            newRequiredSignatures > 0 &&
                newRequiredSignatures <= _signers.length,
            "Invalid number of signatures"
        );

        for (uint256 i = 0; i < _signers.length; i++) {
            address signer = _signers[i];
            require(signer != address(0), "Invalid signer");
            require(!isSigner[signer], "Signer not unique");

            isSigner[signer] = true;
            signers.push(signer);
        }

        requiredSignatures = newRequiredSignatures;
    }

    function removeSigners(
        uint256 index,
        address _signer,
        uint256 newRequiredSignatures
    ) external {
        require(signers.length - 1 >= newRequiredSignatures);
        // Validate owner address corresponds to owner index.
        require(signers[index] == _signer, "not the singer you want to remove");
        isSigner[owner] = false;
        signers[index] = signers[signers.length - 1];
        signers.pop();
        // Change threshold if threshold was changed.
        if (requiredSignatures != newRequiredSignatures)
            requiredSignatures = newRequiredSignatures;
    }

    function executeTransaction(
        address to,
        uint256 value,
        bytes[] memory _signatures
    ) public onlySigner {
        Transaction memory _tx = Transaction({
            value: value,
            executed: true,
            to: to,
            numConfirmations: _signatures.length
        });
        for (uint256 i = 0; i < _signatures.length; i++) {
            Data memory data = Data({
                to: to,
                amount: value
            });
            address _signer = verify(data, _signatures[i]);
            require(isSigner[_signer], "Signature mismatched");
        }
        require(
            _tx.numConfirmations >= requiredSignatures,
            "Cannot execute transaction"
        );

        (bool success, ) = to.call{value: value}("");
        require(success, "Transaction failed");

        emit ExecuteTransaction(msg.sender, to, value);
    }

    function getSigners() public view returns (address[] memory) {
        return signers;
    }

    function getTransaction(uint256 _txIndex)
        public
        view
        returns (
            address to,
            uint256 value,
            bool executed,
            uint256 numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.executed,
            transaction.numConfirmations
        );
    }

    function getTypedDataHash(Data memory data) public pure returns (bytes32) {
        return keccak256(abi.encode(DATA_TYPEHASH, data.to, data.amount));
    }

    function getDigest(Data memory data) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    getTypedDataHash(data)
                )
            );
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (r, s, v);
    }

    function recoverSigner(Data memory data, bytes memory signature)
        public
        view
        returns (address)
    {
        bytes32 digest = getDigest(data);
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        return ecrecover(digest, v, r, s);
    }

    function verify(
        Data memory data,
        bytes memory signature
    ) public view returns (address) {
        return recoverSigner(data, signature);
    }
}
