import Button from "@/components/Button";
import { contractAddr } from "@/contracts/contractData";
import { shortenAddress } from "@/lib/utils";
import { useWeb3Modal, useWeb3ModalAccount } from "@web3modal/ethers/react";
import { ExternalLinkIcon } from "lucide-react";

const Header = () => {
  const { open } = useWeb3Modal();
  const { address, isConnected } = useWeb3ModalAccount();

  return (
    <header className="py-3 border-b">
      <div className="flex items-center justify-between gap-2">
        <div className="flex items-center justify-center gap-3">
          <h1 className="font-bold text-xl">Crowdfunding</h1>
          <a
            href={`https://sepolia.etherscan.io/address/${contractAddr}`}
            target="_blank"
            className="flex items-center gap-1 text-sm p-1 hover:bg-slate-200 transition-colors cursor-pointer rounded-lg"
          >
            {shortenAddress(contractAddr)}
            <ExternalLinkIcon className="w-4 h-4" />
          </a>
        </div>

        <Button
          onClick={() =>
            open({
              view: isConnected ? "Account" : "Connect",
            })
          }
        >
          {isConnected
            ? `${shortenAddress(address as string)}`
            : "Connect Wallet"}
        </Button>
      </div>
    </header>
  );
};

export default Header;
