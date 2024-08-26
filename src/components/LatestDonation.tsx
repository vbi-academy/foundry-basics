import { FundedEvent } from "@/lib/type";
import { shortenAddress } from "@/lib/utils";
import { ExternalLink, LoaderCircle } from "lucide-react";
import Card from "./Card";

interface LatestDonationProps {
  isLoading: boolean;
  latestEvents: FundedEvent[] | null;
}

const LatestDonation = ({ isLoading, latestEvents }: LatestDonationProps) => {
  return (
    <div className="py-4">
      <h2 className="font-semibold">Latest Donation</h2>
      <div className="mt-4 space-y-3">
        {isLoading && <LoaderCircle className="animate-spin" />}
        {!isLoading && !latestEvents && (
          <p className="text-sm">No data to show.</p>
        )}
        {!isLoading &&
          latestEvents &&
          latestEvents.map((item) => (
            <Card
              key={item.txHash}
              className="shadow-none flex justify-between gap-2 items-center hover:shadow-md transition-all"
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
  );
};

export default LatestDonation;
