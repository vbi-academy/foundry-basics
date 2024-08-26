import { ExternalLink, LoaderCircle } from "lucide-react";
import Card from "./components/Card";
import { MainLayout } from "./layouts/MainLayout";
import { createWeb3Modal, defaultConfig } from "@web3modal/ethers/react";
import useEthers from "./hooks/useEthers";
import { useEffect, useState } from "react";
import {
  getContractBalance,
  getFundedEvents,
  getFundersLength,
} from "./contracts/contractInteractions";
import { contractAddr } from "./contracts/contractData";
import FundCard from "./components/FundCard";
import { shortenAddress } from "./lib/utils";

const projectId = import.meta.env.VITE_WALLETCONNECT_PROJECT_ID;

const sepolia = {
  chainId: 11155111,
  name: "Sepolia",
  currency: "ETH",
  explorerUrl: "https://sepolia.etherscan.io/",
  rpcUrl: import.meta.env.VITE_SEPOLIA_RPC_URL,
};

const metadata = {
  name: "Crowfunding",
  description: "Website help people donation for me",
  url: "https://mywebsite.com", // custom your domain here
  icons: ["https://avatars.mywebsite.com/"], //custom your logo here
};

const ethersConfig = defaultConfig({
  metadata,
  enableEIP6963: true,
  enableInjected: true,
  enableCoinbase: true,
});

createWeb3Modal({
  ethersConfig,
  chains: [sepolia],
  projectId,
  enableAnalytics: true,
});

function App() {
  const { provider } = useEthers();
  const [crowdfBalance, setCrowdfBalance] = useState<string | null>(null);
  const [funders, setFunders] = useState<number | null>(null);
  const [latestEvents, setLatestEvents] = useState<any | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  const fetchCrowfundingInfor = async () => {
    setIsLoading(true);
    try {
      if (provider) {
        const balance = await getContractBalance(provider, contractAddr);
        const funders = await getFundersLength(provider);
        const events = await getFundedEvents(provider);
        setCrowdfBalance(balance);
        setFunders(funders);
        setLatestEvents(events);
      }
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchCrowfundingInfor();
  }, [provider]);

  return (
    <MainLayout>
      <div className="flex gap-4 mt-4 pb-4 border-b">
        <div className="w-[30%] space-y-4">
          <Card className="space-y-2">
            <h2 className="font-semibold text-sm">Total amount funding</h2>
            {isLoading && <LoaderCircle className="animate-spin" />}
            {!isLoading && crowdfBalance !== null && (
              <p className="font-bold text-2xl">
                {crowdfBalance}
                <span className="font-semibold text-base">ETH</span>
              </p>
            )}
          </Card>
          <Card className="space-y-2">
            <h2 className="font-semibold text-sm">Funders</h2>
            {isLoading && <LoaderCircle className="animate-spin" />}
            {!isLoading && funders !== null && (
              <p className="font-bold text-2xl">{funders}</p>
            )}
          </Card>
        </div>
        <FundCard fetchContractInfor={fetchCrowfundingInfor} />
      </div>

      <div className="py-4">
        <h2 className="font-semibold">Latest Donation</h2>
        <div className="mt-4 space-y-3">
          {isLoading && <LoaderCircle className="animate-spin" />}
          {!isLoading && !latestEvents && (
            <p className="text-sm">No data to show.</p>
          )}
          {!isLoading &&
            latestEvents &&
            latestEvents.map((item: any) => (
              <Card
                key={item.txHash}
                className="shadow-none flex justify-between gap-2 items-center"
              >
                <div>
                  <span className="text-sm">Funder:</span>

                  <a
                    target="_blank"
                    href={`https://sepolia.etherscan.io/address/${item.funder}`}
                    className="flex items-center gap-1 hover:underline transition-all"
                  >
                    {shortenAddress(item.funder)}
                    <ExternalLink className="w-4 h-4" />
                  </a>
                </div>
                <div className="flex flex-col items-center">
                  <span className="text-sm">Value:</span>
                  <p>{item.value} ETH</p>
                </div>
                <div>
                  <span className="text-sm">Transaction:</span>
                  <a
                    target="_blank"
                    href={`https://sepolia.etherscan.io/tx/${item.txHash}`}
                    className="flex items-center gap-1 hover:underline transition-all"
                  >
                    {shortenAddress(item.txHash)}
                    <ExternalLink className="w-4 h-4" />
                  </a>
                </div>
              </Card>
            ))}
        </div>
      </div>
    </MainLayout>
  );
}

export default App;
