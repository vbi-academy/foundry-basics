import { Contract, formatEther, parseEther } from "ethers";
import { JsonRpcSigner } from "ethers";
import { BrowserProvider } from "ethers";
import { contractABI, contractAddr } from "./contractData";
import { TransactionResponse } from "ethers";

// Read contract
export const getContractBalance = async (
  ethersProvider: BrowserProvider,
  contract: string
) => {
  try {
    const balance = await ethersProvider.getBalance(contract);
    return formatEther(balance);
  } catch (error) {
    return null;
  }
};

export const getFundersLength = async (ethersProvider: BrowserProvider) => {
  try {
    const crowdfundingContract = new Contract(
      contractAddr,
      contractABI,
      ethersProvider
    );
    const fundersLength = await crowdfundingContract.getFundersLength();
    return Number(fundersLength);
  } catch (error) {
    return null;
  }
};

export const getFundedEvents = async (ethersProvider: BrowserProvider) => {
  try {
    const crowdfundingContract = new Contract(
      contractAddr,
      contractABI,
      ethersProvider
    );
    const fundedEventFilter = crowdfundingContract.filters.Funded;
    const fundedEvents = await crowdfundingContract.queryFilter(
      fundedEventFilter,
      10000
    );
    console.log(fundedEvents);
    const events = [];

    for (let i = 0; i < fundedEvents.length; i++) {
      const currentEvent = fundedEvents[i];

      const eventObj = {
        funder: (currentEvent as any).args[0],
        value: formatEther((currentEvent as any).args[1]),
        txHash: currentEvent.transactionHash,
        blockNumber: currentEvent.blockNumber,
      };

      events.push(eventObj);
    }

    if (events.length !== 0)
      return events.sort((a, b) => b.blockNumber - a.blockNumber);
  } catch (error) {
    return null;
  }
};

// Write contract
export const handleFundToContract = async (
  signer: JsonRpcSigner,
  value: number
) => {
  try {
    const crowdfundingContract = new Contract(
      contractAddr,
      contractABI,
      signer
    );
    const tx: TransactionResponse = await crowdfundingContract.fund({
      value: parseEther(String(value)),
    });
    return tx;
  } catch (error) {
    return null;
  }
};
