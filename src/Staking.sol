pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingPoolContract {
    address public owner;

    struct StakingPool {
        IERC20 stakingToken;
        uint256 rewardPercentage;
        uint256 minDuration;
        mapping(address => Stake) stakes;
        uint256 totalStaked;
    }

    struct Stake {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(uint256 => StakingPool) public pools;
    uint256 public poolCount;

    event PoolCreated(uint256 indexed poolId, address indexed tokenAddress, uint256 rewardPercentage, uint256 minDuration);
    event Staked(uint256 indexed poolId, address indexed user, uint256 amount);
    event Withdrawn(uint256 indexed poolId, address indexed user, uint256 amount, uint256 reward);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function createPool(
        address _stakingToken,
        uint256 _rewardPercentage,
        uint256 _minDuration
    ) external onlyOwner {
        require(_stakingToken != address(0));
        require(_rewardPercentage > 0);
        require(_minDuration > 0);

        poolCount++;
        StakingPool storage newPool = pools[poolCount];
        newPool.stakingToken = IERC20(_stakingToken);
        newPool.rewardPercentage = _rewardPercentage;
        newPool.minDuration = _minDuration;
        newPool.totalStaked = 0;

        emit PoolCreated(poolCount, _stakingToken, _rewardPercentage, _minDuration);
    }

    function stake(uint256 _poolId, uint256 _amount) external {
        require(_poolId > 0 && _poolId <= poolCount);
        require(_amount > 0);

        StakingPool storage pool = pools[_poolId];
        require(address(pool.stakingToken) != address(0));

        pool.stakingToken.transferFrom(msg.sender, address(this), _amount);

        Stake storage userStake = pool.stakes[msg.sender];
        if (userStake.amount == 0) {
            userStake.timestamp = block.timestamp;
        }
        userStake.amount += _amount;

        pool.totalStaked += _amount;

        emit Staked(_poolId, msg.sender, _amount);
    }

    function withdraw(uint256 _poolId) external {
        require(_poolId > 0 && _poolId <= poolCount);

        StakingPool storage pool = pools[_poolId];
        require(address(pool.stakingToken) != address(0));

        Stake storage userStake = pool.stakes[msg.sender];
        require(userStake.amount > 0);

        require(block.timestamp >= userStake.timestamp + pool.minDuration);

        uint256 amountToWithdraw = userStake.amount;
        uint256 reward = (amountToWithdraw * pool.rewardPercentage) / 10000;

        delete pool.stakes[msg.sender];

        pool.totalStaked -= amountToWithdraw;

        pool.stakingToken.transfer(msg.sender, amountToWithdraw + reward);

        emit Withdrawn(_poolId, msg.sender, amountToWithdraw, reward);
    }

    function getPoolDetails(uint256 _poolId)
        external
        view
        returns (
            address stakingToken,
            uint256 rewardPercentage,
            uint256 minDuration,
            uint256 totalStaked
        )
    {
        require(_poolId > 0 && _poolId <= poolCount);

        StakingPool storage pool = pools[_poolId];
        return (
            address(pool.stakingToken),
            pool.rewardPercentage,
            pool.minDuration,
            pool.totalStaked
        );
    }

    function getUserStake(uint256 _poolId, address _user)
        external
        view
        returns (uint256 amount, uint256 timestamp)
    {
        require(_poolId > 0 && _poolId <= poolCount);

        Stake storage userStake = pools[_poolId].stakes[_user];
        return (userStake.amount, userStake.timestamp);
    }
}