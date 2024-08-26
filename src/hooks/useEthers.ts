import { useState, useEffect } from "react";
import { BrowserProvider, AlchemyProvider } from "ethers";
import { useWeb3ModalProvider } from "@web3modal/ethers/react";
import { JsonRpcSigner } from "ethers";

interface UseEthersReturn {
  provider: BrowserProvider | AlchemyProvider | null;
  signer: JsonRpcSigner | null;
}

function useEthers(): UseEthersReturn {
  const { walletProvider } = useWeb3ModalProvider();
  const [provider, setProvider] = useState<
    BrowserProvider | AlchemyProvider | null
  >(null);
  const [signer, setSigner] = useState<JsonRpcSigner | null>(null);

  useEffect(() => {
    async function initProvider() {
      try {
        if (walletProvider) {
          const browserProvider = new BrowserProvider(walletProvider);
          setProvider(browserProvider);

          const newSigner = await browserProvider.getSigner();
          setSigner(newSigner);
        } else {
          const alchemyApiKey = import.meta.env.VITE_ALCHEMY_API_KEY;
          if (!alchemyApiKey) {
            throw new Error("Alchemy API key is not set");
          }
          const defaultProvider = new AlchemyProvider("sepolia", alchemyApiKey);
          setProvider(defaultProvider);
          setSigner(null);
        }
      } catch (error) {
        console.error("Failed to initialize provider:", error);
        setProvider(null);
        setSigner(null);
      }
    }

    initProvider();
  }, [walletProvider]);

  return { provider, signer };
}

export default useEthers;
