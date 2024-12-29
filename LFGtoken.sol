/**
 *   _      ______ _____ 
 *  | |    |  ____/ ____|
 *  | |    | |__ | |  __ 
 *  | |    |  __|| | |_ |
 *  | |____| |   | |__| |
 *  |______|_|    \_____|
 *                       
 *  Submitted for verification at snowscan.xyz
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// ERC20 temel implementasyonu
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

abstract contract ERC20 is Context, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    
    // Token holder yönetimi için değişkenleri buraya ekliyoruz
    mapping(address => bool) private _isTokenHolder;
    address[] private _tokenHolders;
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    
    function name() public view virtual returns (string memory) {
        return _name;
    }
    
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        
        emit Transfer(from, to, amount);
        
        _afterTokenTransfer(from, to, amount);
    }
    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        
        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
        
        _afterTokenTransfer(address(0), account, amount);
    }
    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 /* amount */
    ) internal virtual {
        // Yeni token holder'ı ekle
        if (to != address(0) && !_isTokenHolder[to] && balanceOf(to) > 0) {
            _isTokenHolder[to] = true;
            _tokenHolders.push(to);
        }
        
        // Eğer gönderen kişinin token'ı kalmadıysa listeden çıkar
        if (from != address(0) && balanceOf(from) == 0) {
            _isTokenHolder[from] = false;
            _removeTokenHolder(from);
        }
    }
    
    function _removeTokenHolder(address holder) private {
        for (uint256 i = 0; i < _tokenHolders.length; i++) {
            if (_tokenHolders[i] == holder) {
                _tokenHolders[i] = _tokenHolders[_tokenHolders.length - 1];
                _tokenHolders.pop();
                break;
            }
        }
    }
    
    function _getTokenHolders() internal view returns (address[] memory) {
        return _tokenHolders;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    }
    
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// Upgradeable temel kontratı ekleyelim
abstract contract Initializable {
    bool private _initialized;
    bool private _initializing;

    modifier initializer() {
        require(!_initialized && !_initializing, "Initializable: contract is already initialized");
        _initializing = true;
        _;
        _initialized = true;
        _initializing = false;
    }
}

// UUPS Proxy kontratı
abstract contract UUPSUpgradeable is Initializable {
    address private _implementation;
    
    event Upgraded(address indexed implementation);
    
    modifier onlyProxy() {
        require(address(this) != _implementation, "Function must be called through proxy");
        _;
    }
    
    function upgradeTo(address newImplementation) external virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCall(newImplementation, "");
    }
    
    function _authorizeUpgrade(address newImplementation) internal virtual;
    
    function _upgradeToAndCall(address newImplementation, bytes memory data) internal {
        _implementation = newImplementation;
        emit Upgraded(newImplementation);
        
        if(data.length > 0) {
            (bool success,) = newImplementation.delegatecall(data);
            require(success, "Call failed");
        }
    }
}

// Interface for Avalanche C-Chain API calls
interface IAvalancheRPC {
    function eth_getBlockByNumber(bytes32 blockNumber, bool fullTx) external view returns (
        bytes32 number,
        bytes32 hash,
        address miner,
        address[] memory transactions
    );
    
    function eth_getTransactionCount(address account) external view returns (uint256);
}

// Ana kontratımızı upgrade edilebilir yapalım
contract LFGenesiss is ERC20, Ownable, UUPSUpgradeable {
    // Sabitler
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10**18; // 1 milyon max arz
    uint256 public constant INITIAL_OWNER_ALLOCATION = 100_000 * 10**18;
    uint256 public constant PHASE_WALLET_COUNT = 1_000;
    uint256 public constant REFLECTION_TOKEN_HOLDERS = 300;
    uint256 public constant REFLECTION_ACTIVE_USERS = 33;
    uint256 public constant MIN_AVAX_BALANCE = 0.1 ether;

    // Mint limitleri için değişkenler
    uint256 public constant INITIAL_MINT_LIMIT = 100;  // İlk fazdaki mint limiti
    uint256 public constant INITIAL_COOLDOWN = 1 minutes; // İlk fazdaki bekleme süresi
    
    // Mint takibi için değişkenler
    uint256 public lastMintTimestamp;
    uint256 public currentMintCount;
    mapping(address => uint256) public lastMintBlock;

    uint256 public totalMintedWallets;
    uint256 public totalReflected;
    uint256 public totalBurned;
    mapping(address => bool) public hasMinted;

    event TokensMinted(address indexed wallet, uint256 amount, uint256 reflectionAmount);
    event TokensBurned(uint256 amount);
    event ReflectionDistributed(uint256 amount);

    // Airdrop için gerekli değişkenler
    mapping(address => bool) public hasClaimed;
    uint256 public constant MAX_AIRDROP_HOLDERS = 140;
    address public constant OLD_TOKEN = 0x69CB4b27a800334F467B3F322089011c9DD2e1d4;
    
    event AirdropClaimed(address indexed holder, uint256 amount);

    // Reflection için token adresleri
    address public constant ARENA = 0xB8d7710f7d8349A506b75dD184F05777c82dAd0C;
    address public constant COQ = 0x420FcA0121DC28039145009570975747295f2329;
    address public constant TECH = 0x5Ac04b69bDE6f67C0bd5D6bA6fD5D816548b066a;
    address public constant NOCHILL = 0xAcFb898Cff266E53278cC0124fC2C7C94C8cB9a5;

    constructor() ERC20("LFGenesis", "LFGEN") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_OWNER_ALLOCATION);
    }

    function isEligibleForMint(address wallet) public view returns (bool) {
        // Sadece daha önce mint yapmamış olma kontrolü
        return !hasMinted[wallet];
    }

    function mint() external {
        require(isEligibleForMint(msg.sender), "Not eligible for minting");
        require(totalSupply() < MAX_SUPPLY, "Max supply reached");
        
        uint256 mintAmount = getCurrentMintAmount(); // Örneğin 10 token
        uint256 userAmount = mintAmount / 2; // Kullanıcıya gidecek miktar (%50 - 5 token)
        uint256 reflectionAndBurnAmount = mintAmount - userAmount; // Geriye kalan %50 (5 token)
        
        // Reflection ve burn için olan miktarın dağılımı
        uint256 burnAmount = (reflectionAndBurnAmount * 10) / 100; // %10'u burn (0.5 token)
        uint256 reflectionAmount = reflectionAndBurnAmount - burnAmount; // Kalanı reflection (4.5 token)

        // Toplam arz kontrolü
        require(totalSupply() + mintAmount <= MAX_SUPPLY, "Would exceed max supply");
        
        // Eğer yeni bir mint seansı başlıyorsa
        if(block.timestamp >= lastMintTimestamp + getCurrentCooldown()) {
            currentMintCount = 0;
        }
        
        hasMinted[msg.sender] = true;
        lastMintBlock[msg.sender] = block.number;
        lastMintTimestamp = block.timestamp;
        currentMintCount++;
        totalMintedWallets++;
        
        // Kullanıcıya kendi payını ver
        _mint(msg.sender, userAmount);
        
        // Burn işlemi
        _mint(address(this), burnAmount);
        _burn(address(this), burnAmount);
        totalBurned += burnAmount;
        emit TokensBurned(burnAmount);
        
        // Reflection dağıtımı
        if (reflectionAmount > 0) {
            _distributeReflection(reflectionAmount);
        }
        
        emit TokensMinted(msg.sender, userAmount, reflectionAmount);
    }

    function _distributeReflection(uint256 amount) internal {
        // Token holder'lara dağıtılacak miktar (toplam miktarın %90'ı)
        uint256 amountForHolders = (amount * 90) / 100;
        // Aktif kullanıcılara dağıtılacak miktar (toplam miktarın %10'u)
        uint256 amountForActive = amount - amountForHolders;
        
        // Token holder'lara dağıtım
        address[] memory holders = _getTokenHolders();
        if (holders.length > 0) {
            uint256 holderCount = holders.length < REFLECTION_TOKEN_HOLDERS ? holders.length : REFLECTION_TOKEN_HOLDERS;
            uint256 amountPerHolder = amountForHolders / holderCount;
            
            for(uint256 i = 0; i < holderCount; i++) {
                uint256 randomIndex = uint256(keccak256(abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    msg.sender,
                    i
                ))) % holders.length;
                
                _mint(holders[randomIndex], amountPerHolder);
            }
        }
        
        // Son 100 blokta işlem yapan cüzdanlara dağıtım
        address[] memory activeUsers = _getRecentActiveAddresses();
        uint256 activeCount = 0;
        for(uint256 i = 0; i < activeUsers.length; i++) {
            if(activeUsers[i] != address(0)) activeCount++;
        }
        
        if(activeCount > 0) {
            uint256 amountPerActive = amountForActive / activeCount;
            for(uint256 i = 0; i < activeCount; i++) {
                if(activeUsers[i] != address(0)) {
                    _mint(activeUsers[i], amountPerActive);
                }
            }
        }
        
        totalReflected += amount;
        emit ReflectionDistributed(amount);
    }

    function _getRecentActiveAddresses() internal view returns (address[] memory) {
        address[] memory activeAddresses = new address[](REFLECTION_ACTIVE_USERS);
        
        // Tüm potansiyel holder'ları topla
        address[] memory allHolders = new address[](1000); // Başlangıç boyutu
        uint256 totalHolders = 0;
        
        // Her token için holder'ları kontrol et
        address[4] memory tokens = [ARENA, COQ, TECH, NOCHILL];
        for(uint256 i = 0; i < tokens.length; i++) {
            address[] memory holders = _getTokenHolders();
            for(uint256 j = 0; j < holders.length; j++) {
                if(IERC20(tokens[i]).balanceOf(holders[j]) > 0) {
                    bool isDuplicate = false;
                    for(uint256 k = 0; k < totalHolders; k++) {
                        if(allHolders[k] == holders[j]) {
                            isDuplicate = true;
                            break;
                        }
                    }
                    if(!isDuplicate) {
                        allHolders[totalHolders] = holders[j];
                        totalHolders++;
                    }
                }
            }
        }
        
        // Eğer yeterli holder yoksa, tüm holder'ları ekle
        if(totalHolders <= REFLECTION_ACTIVE_USERS) {
            for(uint256 i = 0; i < totalHolders; i++) {
                activeAddresses[i] = allHolders[i];
            }
            return activeAddresses;
        }
        
        // Fisher-Yates shuffle algoritması ile rastgele seçim
        for(uint256 i = 0; i < REFLECTION_ACTIVE_USERS; i++) {
            uint256 randomIndex = i + uint256(keccak256(abi.encodePacked(
                block.timestamp,
                block.prevrandao,
                msg.sender,
                totalMintedWallets,
                totalReflected,
                i
            ))) % (totalHolders - i);
            
            // Swap işlemi
            address temp = allHolders[i];
            allHolders[i] = allHolders[randomIndex];
            allHolders[randomIndex] = temp;
            
            activeAddresses[i] = allHolders[i];
        }
        
        return activeAddresses;
    }

    // Toplam arz bilgisi için view fonksiyon
    function getTokenInfo() public view returns (
        uint256 currentSupply,
        uint256 maxSupply,
        uint256 burned,
        uint256 remaining
    ) {
        currentSupply = totalSupply();
        maxSupply = MAX_SUPPLY;
        burned = totalBurned;
        remaining = MAX_SUPPLY - currentSupply;
        return (currentSupply, maxSupply, burned, remaining);
    }

    function initialize() public initializer {
        // Initialize işlemleri
        _mint(msg.sender, INITIAL_OWNER_ALLOCATION);
    }
    
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // İlk 140 adres için airdrop listesi
    function _getOldTokenHolders() internal pure returns (address[] memory) {
        address[] memory holders = new address[](140);
        
        holders[0] = 0x046453BD27F8092A8F9B881a0D11eF4a00454aF9;
        holders[1] = 0x271B281AE431666bD7BE5eCD91AC50a2847539bE;
        holders[2] = 0x1E435D697439aF706572F1800006121D72F890c3;
        holders[3] = 0x7b6C4E585f074D2C50A2e4BF85B589aa4F5bB3A7;
        holders[4] = 0x8C7de13eCf6e92E249696D16c1992Ec41c986F0C;
        holders[5] = 0x2D4C407BBe49438ED859fe965b140dcF1aaB71a9;
        holders[6] = 0xea5B7842EB0D144127E614C86cE6485534823099;
        holders[7] = 0xC1eBa383D94c6021160042491CC41ee14CAfC47C;
        holders[8] = 0x0a1DEfB0fe7Ee2c5B8855Ea0Cb9E466dA7f1eB4c;
        holders[9] = 0x9A1F4fD3637d6090C0ac5D2e2F1E89fB40cE31F8;
        holders[10] = 0x4a8b1C45C6e6f595c3E2e97b04bc31bD4C37e8f2;
        holders[11] = 0x3B9E571db1B4Bf5605c9c1b8c8620F7454918F1B;
        holders[12] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        holders[13] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        holders[14] = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        holders[15] = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4;
        holders[16] = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
        holders[17] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
        holders[18] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        holders[19] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        holders[20] = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;
        holders[21] = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
        holders[22] = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e;
        holders[23] = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
        holders[24] = 0x0D8775F648430679A709E98d2b0Cb6250d2887EF;
        holders[25] = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
        holders[26] = 0x6f259637dcD74C767781E37Bc6133cd6A68aa161;
        holders[27] = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
        holders[28] = 0x0F5D2fB29fb7d3CFeE444a200298f468908cC942;
        holders[29] = 0xE41d2489571d322189246DaFA5ebDe1F4699F498;
        holders[30] = 0x1985365e9f78359a9B6AD760e32412f4a445E862;
        holders[31] = 0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39;
        holders[32] = 0x408e41876cCCDC0F92210600ef50372656052a38;
        holders[33] = 0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD;
        holders[34] = 0xba100000625a3754423978a60c9317c58a424e3D;
        holders[35] = 0x0F83287FF768D1c1e17a42F44d644D7F22e8ee1d;
        holders[36] = 0xD533a949740bb3306d119CC777fa900bA034cd52;
        holders[37] = 0x6810e776880C02933D47DB1b9fc05908e5386b96;
        holders[38] = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
        holders[39] = 0x1494CA1F11D487c2bBe4543E90080AeBa4BA3C2b;
        holders[40] = 0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0;
        holders[41] = 0x0f2D719407FdBeFF09D87557AbB7232601FD9F29;
        holders[42] = 0xAa6E8127831c9DE45ae56bB1b0d4D4Da6e5665BD;
        holders[43] = 0x2ba592F78dB6436527729929AAf6c908497cB200;
        holders[44] = 0x3155BA85D5F96b2d030a4966AF206230e46849cb;
        holders[45] = 0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272;
        holders[46] = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
        holders[47] = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e;
        holders[48] = 0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0;
        holders[49] = 0x4a220E6096B25EADb88358cb44068A3248254675;
        holders[50] = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;
        holders[51] = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
        holders[52] = 0x0D8775F648430679A709E98d2b0Cb6250d2887EF;
        holders[53] = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
        holders[54] = 0x93ED3FBe21207Ec2E8f2d3c3de6e058Cb73Bc04d;
        holders[55] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
        holders[56] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        holders[57] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        holders[58] = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
        holders[59] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        holders[60] = 0x0000000000085d4780B73119b644AE5ecd22b376;
        holders[61] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
        holders[62] = 0x0D8775F648430679A709E98d2b0Cb6250d2887EF;
        holders[63] = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
        holders[64] = 0x93ED3FBe21207Ec2E8f2d3c3de6e058Cb73Bc04d;
        holders[65] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
        holders[66] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        holders[67] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        holders[68] = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
        holders[69] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        holders[70] = 0x0000000000085d4780B73119b644AE5ecd22b376;
        holders[71] = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
        holders[72] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
        holders[73] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        holders[74] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        holders[75] = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;
        holders[76] = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
        holders[77] = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e;
        holders[78] = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
        holders[79] = 0x0D8775F648430679A709E98d2b0Cb6250d2887EF;
        holders[80] = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
        holders[81] = 0x6f259637dcD74C767781E37Bc6133cd6A68aa161;
        holders[82] = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
        holders[83] = 0x0F5D2fB29fb7d3CFeE444a200298f468908cC942;
        holders[84] = 0xE41d2489571d322189246DaFA5ebDe1F4699F498;
        holders[85] = 0x1985365e9f78359a9B6AD760e32412f4a445E862;
        holders[86] = 0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39;
        holders[87] = 0x408e41876cCCDC0F92210600ef50372656052a38;
        holders[88] = 0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD;
        holders[89] = 0xba100000625a3754423978a60c9317c58a424e3D;
        holders[90] = 0x0F83287FF768D1c1e17a42F44d644D7F22e8ee1d;
        holders[91] = 0xD533a949740bb3306d119CC777fa900bA034cd52;
        holders[92] = 0x6810e776880C02933D47DB1b9fc05908e5386b96;
        holders[93] = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
        holders[94] = 0x1494CA1F11D487c2bBe4543E90080AeBa4BA3C2b;
        
        return holders;
    }

    // Owner için toplu airdrop fonksiyonu
    function distributeAirdrop() external onlyOwner {
        address[] memory oldHolders = _getOldTokenHolders();
        
        for(uint256 i = 0; i < oldHolders.length; i++) {
            address holder = oldHolders[i];
            if(!hasClaimed[holder]) {
                uint256 oldBalance = IERC20(OLD_TOKEN).balanceOf(holder);
                if(oldBalance > 0) {
                    uint256 claimAmount = oldBalance * 10;
                    hasClaimed[holder] = true;
                    _mint(holder, claimAmount);
                    emit AirdropClaimed(holder, claimAmount);
                }
            }
        }
    }

    // Tek bir adrese airdrop gönderme fonksiyonu (ihtiyaç olursa)
    function distributeAirdropToAddress(address holder) external onlyOwner {
        require(!hasClaimed[holder], "Already claimed");
        uint256 oldBalance = IERC20(OLD_TOKEN).balanceOf(holder);
        require(oldBalance > 0, "No balance in old token");
        
        uint256 claimAmount = oldBalance * 10;
        hasClaimed[holder] = true;
        _mint(holder, claimAmount);
        emit AirdropClaimed(holder, claimAmount);
    }

    function getCurrentMintAmount() public view returns (uint256) {
        uint256 currentPhase = 0;
        uint256 walletLimit = PHASE_WALLET_COUNT; // 1,000 başlangıç
        
        // Hangi fazda olduğumuzu hesapla
        while (totalMintedWallets >= walletLimit && walletLimit <= type(uint256).max / 2) {
            currentPhase++;
            walletLimit *= 2; // Her fazda limit 2 katına çıkar (1000, 2000, 4000, 8000...)
        }
        
        // Başlangıç miktarı 10 token (10^18), her fazda yarıya iner
        return 10 * 10**18 / (2**currentPhase);
    }

    function getCurrentReflectionRate() public view returns (uint256) {
        uint256 currentPhase = 0;
        uint256 walletLimit = PHASE_WALLET_COUNT;
        
        while (totalMintedWallets >= walletLimit && walletLimit <= type(uint256).max / 2) {
            currentPhase++;
            walletLimit *= 2;
        }
        
        // Başlangıç reflection oranı %50, her fazda yarıya iner
        return 50 / (2**currentPhase);
    }

    function getCurrentMintLimit() public view returns (uint256) {
        uint256 currentPhase = 0;
        uint256 walletLimit = PHASE_WALLET_COUNT;
        
        // Hangi fazda olduğumuzu hesapla
        while (totalMintedWallets >= walletLimit && walletLimit <= type(uint256).max / 2) {
            currentPhase++;
            walletLimit *= 2;
        }
        
        // Başlangıç limiti 100, her fazda yarıya iner
        return INITIAL_MINT_LIMIT / (2**currentPhase);
    }
    
    function getCurrentCooldown() public view returns (uint256) {
        uint256 currentPhase = 0;
        uint256 walletLimit = PHASE_WALLET_COUNT;
        
        // Hangi fazda olduğumuzu hesapla
        while (totalMintedWallets >= walletLimit && walletLimit <= type(uint256).max / 2) {
            currentPhase++;
            walletLimit *= 2;
        }
        
        // Başlangıç cooldown'u 1 dakika, her fazda 2 katına çıkar
        return INITIAL_COOLDOWN * (2**currentPhase);
    }
    
    // Mevcut mint seansı bilgilerini görüntülemek için
    function getMintSessionInfo() public view returns (
        uint256 remainingTime,
        uint256 remainingMints,
        uint256 currentLimit,
        uint256 currentCooldown
    ) {
        uint256 cooldown = getCurrentCooldown();
        uint256 timeSinceLastMint = block.timestamp - lastMintTimestamp;
        
        if(timeSinceLastMint < cooldown) {
            remainingTime = cooldown - timeSinceLastMint;
        } else {
            remainingTime = 0;
        }
        
        currentLimit = getCurrentMintLimit();
        remainingMints = currentLimit > currentMintCount ? currentLimit - currentMintCount : 0;
        currentCooldown = cooldown;
        
        return (remainingTime, remainingMints, currentLimit, currentCooldown);
    }

    // Detaylı token bilgileri için view fonksiyon
    function getDetailedTokenInfo() public view returns (
        uint256 currentPhase,
        uint256 currentMintAmount,
        uint256 currentReflectionRate,
        uint256 currentCooldownTime,
        uint256 currentMintLimit,
        uint256 totalMinted,
        uint256 totalBurnedAmount,
        uint256 totalReflectedAmount,
        uint256 totalHolderCount,
        uint256 remainingSupply
    ) {
        // Mevcut fazı hesapla
        currentPhase = 0;
        uint256 walletLimit = PHASE_WALLET_COUNT;
        while (totalMintedWallets >= walletLimit && walletLimit <= type(uint256).max / 2) {
            currentPhase++;
            walletLimit *= 2;
        }

        // Diğer bilgileri hesapla
        currentMintAmount = getCurrentMintAmount();
        currentReflectionRate = getCurrentReflectionRate();
        currentCooldownTime = getCurrentCooldown();
        currentMintLimit = getCurrentMintLimit();
        totalMinted = totalSupply();
        totalBurnedAmount = totalBurned;
        totalReflectedAmount = totalReflected;
        totalHolderCount = _getTokenHolders().length;
        remainingSupply = MAX_SUPPLY - totalSupply();

        return (
            currentPhase,
            currentMintAmount,
            currentReflectionRate,
            currentCooldownTime,
            currentMintLimit,
            totalMinted,
            totalBurnedAmount,
            totalReflectedAmount,
            totalHolderCount,
            remainingSupply
        );
    }
}
