pragma solidity ^0.4.18;


contract DataExchangeContractTest {
    

    address public owner;
    event addDataInfo(address addr,uint price, string datahash,string description);
    event buyDataInfo(address buyer,uint price, string datahash, string description);

    // 构建大数据模块的数据结构
    struct DataInfo {
        uint price; // 数据的定价信息
        string datahash; // 数据在ipfs网络上的存储信息
        string description; //数据的描述信息

    }


    // 映射 用户:大数据信息
    mapping(address => DataInfo[]) public DataOwners;
    // 映射 购买者:大数据信息
    mapping(address => DataInfo[]) public Databuyers;
    // 映射 用户:价值 反映用户有多少钱
    mapping(address => uint) pendingWithdrawals; 

    // 构造函数
    constructor(){
        owner = msg.sender;
    }

    // 注册函数
    function register(uint price, string datahash, string description) public { 
        DataOwners[msg.sender].push(
            DataInfo({price:price,datahash:datahash,description:description})
            );
        emit addDataInfo(msg.sender,price,datahash,description);
    }

    // 修改已有的数据信息
    function modifyExistingDataInfo(uint index, uint price, string datahash, string description) public {
        
        require(index < DataOwners[msg.sender].length,"在这个位置上你的内容为空，你不能修改这个数据信息");
        DataInfo datainfo = DataOwners[msg.sender][index];
        datainfo.price = price;
        datainfo.datahash = datahash;
        datainfo.description = description;
    }

    // 购买数据函数
    function Buy(address dataowneraddr, uint dataindex) public payable returns(string){
        
        require(DataOwners[dataowneraddr][dataindex].price <= msg.value,"你付的钱不足以购买该信息");
        
        pendingWithdrawals[dataowneraddr] += msg.value; // 存储账户价值
        emit buyDataInfo(msg.sender,DataOwners[dataowneraddr][dataindex].price,DataOwners[dataowneraddr][dataindex].datahash,DataOwners[dataowneraddr][dataindex].description);
        
        return DataOwners[dataowneraddr][dataindex].datahash;

    }

    // 显示信息函数
    function getDataPrice(address dataowneraddr, uint dataindex) public returns(uint){
        var price = DataOwners[dataowneraddr][dataindex].price;
        
        return price;
    }

    function getDataDescription(address dataowneraddr, uint dataindex ) public returns(string){
        var description = DataOwners[dataowneraddr][dataindex].description;
        
        return description;
    }

    // 使用withdraw方法使得数据拥有者受到数据的价值信息。避免用户阻塞buy函数导致合约不可用
    function withdraw() public {

        uint amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender]=0;
        msg.sender.transfer(amount);
        
    }


}
