<div align="center">

<h1>Foundry Basics Course</h1>

<strong>Học cách phát triển Smart Contract Solidity bằng thư viện Foundry</strong>

<p align="center">
<a href="https://www.youtube.com/@VBIAcademy">
        <img src=".github/images/vbi-powered-badge.png" width="145" alt=""/></a>
</p>
Chào mừng bạn đến với repository của khoá học Foundry Basics. <br/> Khoá học này được phát triển bởi <a href="https://www.youtube.com/@VBIAcademy">VBI Academy</a> và <a href="https://www.terrancrypt.com/">Terran Crypt</a>.

</div>

---
> Nội dung trong khoá học này đã được sự cho phép chọn lọc và dịch thuật từ các khoá học được phát triển và giảng dạy bởi [Cyfrin Updraft](https://updraft.cyfrin.io/) và [Patrick Collins](https://www.youtube.com/@PatrickAlphaC).
---

## Mở đầu

Tiếp nối khoá học [Solidity Basics](https://github.com/openedu101/solidity-basics), trong khoá học này chúng ta sẽ học cách sử dụng Foundry cho việc xây dựng smart contract Solidity. Hãy chắc chắn rằng bạn đã có kiến thức cơ bản về Blockchain và Solidity trước khi chúng ta học khoá này.

Group hỗ trợ: <a href="https://discord.gg/htjprg2Puy" style="text-decoration: underline;">Solidity Developer Vietnam</a>

## Section 1: Local Development w/ Foundry

Foundry là một bộ công cụ phát triển smart contract cho Ethereum, được viết bằng Rust. Nó được thiết kế để hỗ trợ việc phát triển, kiểm thử và triển khai smart contract Solidity một cách hiệu quả.

- Các thành phần chính:

  - Forge: Công cụ kiểm thử và biên dịch smart contract
  - Cast: Công cụ dòng lệnh để tương tác với blockchain Ethereum
  - Anvil: Node Ethereum cục bộ để phát triển và kiểm thử

- Ưu điểm chính:

  - Tốc độ: Được viết bằng Rust, Foundry thực hiện các tác vụ như biên dịch và kiểm thử nhanh hơn so với nhiều công cụ khác.
  - Kiểm thử mạnh mẽ: Hỗ trợ viết và chạy các bài kiểm tra bằng Solidity, cho phép kiểm tra kỹ lưỡng logic của smart contract.
  - Tích hợp với các công cụ khác: Dễ dàng tích hợp với các công cụ phát triển phổ biến khác.
  - Debugger tích hợp: Giúp dễ dàng tìm và sửa lỗi trong smart contract.

- Cách sử dụng:

  - Viết smart contract bằng Solidity
  - Sử dụng Forge để biên dịch và kiểm thử contract
  - Sử dụng Cast để tương tác với blockchain
  - Sử dụng Anvil để chạy một node Ethereum cục bộ cho phát triển

### Cài đặt Foundry & Thiết lập môi trường phát triển


- [Visual Studio Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)
- [Foundry Documentation](https://book.getfoundry.sh/)
- [Solidity - VSCode Extension](https://marketplace.visualstudio.com/items?itemName=JuanBlanco.solidity)

### Forge & Anvil

Code trong phần này sử dụng contract SimpleStorage trong khoá Solidity Basics: [tại đây](https://github.com/openedu101/solidity-basics/tree/01-remix-simple-storage)

Final Code: [tại đây](https://github.com/openedu101/foundry-basics/tree/01-simple-storage)

- Compile contract:

```
forge compile
```

- Format code:

```bash
forge fmt
```

- Run local Anvil chain:

```bash
anvil
```

#### Deploy contract lên mạng local

Có 2 cách để deploy:

- Với `create`

```bash
forge create SimpleStorage --rpc-url http://127.0.0.1:8545 --interactive
```

```bash
forge create SimpleStorage --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

Cách sử dụng `--interactive` tốt hơn, không lưu private key dưới dạng plain text trong terminal.

- Với `script`

```bash
forge script script/DeploySimpleStorage.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

![Private Key Caution](.github/images/private-key-caution.png)

#### Bảo mật private key với `cast wallet`

- Tạo account mới để lưu trữ private key: 

```bash
cast wallet import <ACCOUNT_NAME> --interactive
```

- Xem danh sách các account đã tạo
```bash
cast wallet list
```

#### Giải thích deploy transactions

- Chuyển hex value thành decimal value: 
```bash
cast --to-base {hex} dec
```

#### Tương tác với contract đã được deploy

- Send transaction:
```bash
cast send <CONTRACT_ADDRESS> <FUNCTION_SIGNATURE> <ARGS> --rpc-url <YOUR_RPC_URL> --account <ACCOUNT_NAME>
```

- Call transaction:
```bash
cast call <CONTRACT_ADDRESS> <FUNCTION_SIGNATURE> <ARGS> --rpc-url <YOUR_RPC_URL>
```

#### Lấy RPC-URL trên Alchemy
- [Alchemy](https://www.alchemy.com/)

#### Deploy và verify contract trên Sepolia Testnet
- [Sepolia Etherscan](https://sepolia.etherscan.io/)
  
- Ví dụ về contract đã được deploy và verify: [Simple Storage](https://sepolia.etherscan.io/address/0xee38c811f888a24b962c17539285c2daaad5bba8#code)

- Sử dụng ENV file để bảo mật các giá trị riêng tư: [ENV Example](https://github.com/openedu101/foundry-basics/blob/01-simple-storage/.env.example)

- Sử dụng ENV Variables trong terminal: 

```bash
source .env
```

```bash
forge script script/DeploySimpleStorage.s.sol --rpc-url ${SEPOLIA_RPC_URL} --account <ACCOUNT_NAME> --broadcast 
```

- Verify contract:

```bash
forge verify-contract <CONTRACT_ADDRESS> <PATH>:<CONTRACT_NAME> --rpc-url ${SEPOLIA_RPC_URL} --etherscan-api-key ${ETHERSCAN_API_KEY}
```

- Verify contract khi deploy contract:
```bash
forge script script/DeploySimpleStorage.s.sol --rpc-url ${SEPOLIA_RPC_URL} --account <ACCOUNT_NAME> --broadcast  --verify --etherscan-api-key ${ETHERSCAN_API_KEY}
```

Lưu ý là nếu muốn verify contract trong khi deploy thì chỉ có thể sử dụng script bởi vì khi deploy thì script sẽ chứa luôn đường dẫn đến file của contract.

#### Makefile

- [Makefile Tutorial](https://makefiletutorial.com/)
- [Cài Makefile cho Windows](https://medium.com/@samsorrahman/how-to-run-a-makefile-in-windows-b4d115d7c516)

## Section 2: Smart Contracts Testing w/ Foundry

Code khởi đầu sử dụng contract `Crowdfunding` trong khoá Blockchain Basics:  [tại đây](https://github.com/openedu101/solidity-basics/tree/03-decentralized-crowdfunding)

Final code: [tại đây](https://github.com/openedu101/foundry-basics/tree/02-decentralized-crowdfunding)

Contract đã được deploy và verify: [tại đây](https://sepolia.etherscan.io/address/0x211402ce31ca3e7f4fa7008462d9f3c8b5c01ce7)

### Các loại testing smart contract cơ bản

1. Unit:
   - Kiểm tra một phần cụ thể trong code.
2. Integration:
   - Kiểm tra hoạt động của code với các phần khác trong dự án.
3. Forked:
   - Kiểm tra code với giả lập môi trường thực tế.
4. Staging:
   - Kiểm tra code trong một môi trường thực tế (testnet) nhưng không phải production (mainnet).