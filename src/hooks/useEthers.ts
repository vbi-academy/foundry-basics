import { useState, useEffect } from "react";
import { BrowserProvider, JsonRpcSigner } from "ethers";
import { useWeb3ModalProvider } from "@web3modal/ethers/react";

interface UseEthersReturn {
  provider: BrowserProvider | null;
  signer: JsonRpcSigner | null;
}

function useEthers(): UseEthersReturn {
  const { walletProvider } = useWeb3ModalProvider();
  const [provider, setProvider] = useState<BrowserProvider | null>(null);
  const [signer, setSigner] = useState<JsonRpcSigner | null>(null);

  useEffect(() => {
    async function initProvider() {
      if (walletProvider) {
        const browserProvider = new BrowserProvider(walletProvider);
        setProvider(browserProvider);

        const signer = await browserProvider.getSigner();
        setSigner(signer);
      }
    }

    initProvider();
  }, [walletProvider]);

  return { provider, signer };
}

export default useEthers;
