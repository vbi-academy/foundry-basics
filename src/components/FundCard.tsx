import { ExternalLink, HandCoins, LoaderCircle, SmilePlus } from "lucide-react";
import Button from "./Button";
import Card from "./Card";
import { useState } from "react";
import { handleFundToContract } from "@/contracts/contractInteractions";
import useEthers from "@/hooks/useEthers";
import { shortenAddress } from "@/lib/utils";
import facebookIcon from "@/assets/facebook.svg";
import githubIcon from "@/assets/github.svg";
import youtubeIcon from "@/assets/youtube.svg";

interface FundCardProps {
  fetchContractInfor: () => void;
}

const FundCard = ({ fetchContractInfor }: FundCardProps) => {
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [isSuccess, setIsSuccess] = useState<boolean>(false);
  const [txHash, setTxHash] = useState<string | null>(null);
  const [value, setValue] = useState<number>(0);
  const { signer } = useEthers();

  const onFundToContract = async () => {
    setIsLoading(true);
    try {
      if (value === 0) {
        alert("Amount must be provide!");
        return;
      }
      if (signer && value !== null) {
        const tx = await handleFundToContract(signer, value);

        if (tx) {
          setTxHash(tx?.hash);
          await tx.wait();

          setIsSuccess(true);
          fetchContractInfor();
        }
      }
    } catch (error) {
      console.error(error);
      alert("Transaction error!");
    } finally {
      setIsLoading(false);
    }
  };

  const onChangeValue = async (e: React.ChangeEvent<HTMLInputElement>) => {
    setValue(Number(e.target.value));
  };

  const onCloseSuccess = () => {
    setIsSuccess(false);
    setValue(0);
    setTxHash(null);
  };

  return (
    <Card className="w-[70%] space-y-2 py-10 relative overflow-hidden">
      {isLoading && (
        <div className="flex gap-3 items-center">
          <LoaderCircle className="w-8 h-8 animate-spin" />
          <div className="text-sm space-y-1">
            <p>Transation in progress...</p>
            {txHash && (
              <a
                target="_blank"
                href={`https://sepolia.etherscan.io/tx/${txHash}`}
                className="flex items-center gap-1 hover:underline transition-all"
              >
                {shortenAddress(txHash)}
                <ExternalLink className="w-4 h-4" />
              </a>
            )}
          </div>
        </div>
      )}
      {!isLoading && !isSuccess && (
        <>
          <div className="flex items-center">
            <a
              target="_blank"
              href="https://www.youtube.com/@terrancrypt"
              className="p-2 rounded-lg hover:bg-slate-200 transition-colors"
            >
              <img className="w-6 h-6" src={youtubeIcon} alt="youtube icon" />
            </a>
            <a
              target="_blank"
              href="https://www.facebook.com/terrancrypt/"
              className="p-2 rounded-lg hover:bg-slate-200 transition-colors"
            >
              <img className="w-6 h-6" src={facebookIcon} alt="youtube icon" />
            </a>
            <a
              target="_blank"
              href="https://github.com/terrancrypt"
              className="p-2 rounded-lg hover:bg-slate-200 transition-colors"
            >
              <img className="w-6 h-6" src={githubIcon} alt="youtube icon" />
            </a>
          </div>
          <h2 className="font-semibold text-xl">Donate your Ether</h2>
          <div className="space-x-2">
            <input
              placeholder="Amount"
              className="p-2 border rounded-lg text-sm"
              type="number"
              onChange={onChangeValue}
            />
            <Button className="w-fit" onClick={() => onFundToContract()}>
              Fund
            </Button>
          </div>
        </>
      )}
      {!isLoading && isSuccess && (
        <div className="space-y-4">
          <div className="flex gap-2 items-center">
            <SmilePlus className="w-8 h-8 text-green-500" />
            <p className="font-semibold text-lg">
              Thank you! Your Donation Successful!
            </p>
          </div>
          {txHash && (
            <span className="flex gap-1">
              Transaction:
              <a
                target="_blank"
                href={`https://sepolia.etherscan.io/tx/${txHash}`}
                className="flex items-center gap-1 hover:underline transition-all"
              >
                {shortenAddress(txHash)}
                <ExternalLink className="w-4 h-4" />
              </a>
            </span>
          )}
          <Button onClick={() => onCloseSuccess()}>Okay</Button>
        </div>
      )}
      <HandCoins className="absolute right-2 top-1/2 -translate-y-[50%] w-36 h-36 -z-10 text-gray-200" />
    </Card>
  );
};

export default FundCard;
