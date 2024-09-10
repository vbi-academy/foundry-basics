## Dependencies

- [Chainlink](https://github.com/smartcontractkit/chainlink)@v2.14.0
- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts)@v5.0.2
- [Foundry DevOps](https://github.com/Cyfrin/foundry-devops)@0.2.2
  

## Deployment

1. Thêm các Enviroment Enviroments: 

- `SEPOLIA_RPC_URL`: RPC_URL của chain mà bạn muốn, không nhất thiết phải là Sepolia.
- `ETHERSCAN_API_KEY`: API key của Block Explorer để verify contract sau khi deploy.
- `ACCOUNT`: tên account được lưu trữ trong `cast wallet`. Account này lưu private key của bạn dùng để deploy / run scripts một cách an toàn.

2. Chuẩn bị Native Token và LINK Token của chain đó:

Nếu sử dụng testnet, bạn cần có testnet native token và LINK token của chain đó. Lấy tại đây: [faucets.chain.link](https://faucets.chain.link/).

3. Create Chainlink VRF Subscription:

- Truy cập: [vrf.chain.link](https://vrf.chain.link/)
- Connect Wallet, với chain mà bạn chọn.
- Ấn Create Subscription.
- Fund Subscription với tầm khoảng 4 LINK.
- Sau khi có SubscriptionId thì thay đổi nó trong file `script/HelperConfig.s.sol`:

```solidity
function getSepoliaNetworkConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            subscriptionId: , // thay đổi tại đây
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B, // cho Sepolia ETH
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae, // cho Sepolia ETH
            linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789, // cho Sepolia ETH
            automationInterval: 30 // Thời gian mà bạn muốn Chainlink Automation chạy mỗi lần check.
        });
    }
```

4. Deploy:

```bash
make deploy ARGS="--network sepolia"
```

5. Register new Chainlink Automation Upkeep

- Truy cập: [automation.chain.link](https://automation.chain.link/)
- Ấn Register new Upkeep.
- Chọn Trigger => Custom Logic.
- Nhập vào địa chỉ address của contract đã deploy ở bước 4 phía trên.