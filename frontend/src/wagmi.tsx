import "@rainbow-me/rainbowkit/styles.css";
import { getDefaultConfig, RainbowKitProvider } from "@rainbow-me/rainbowkit";
import { WagmiProvider } from "wagmi";
import { mainnet, polygon, optimism, arbitrum, base, sepolia, anvil } from "wagmi/chains";
import { QueryClientProvider, QueryClient } from "@tanstack/react-query";

export default getDefaultConfig({
  appName: "My RainbowKit App",
  projectId: import.meta.env.VITE_NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID!,
  chains: [base, anvil],
  ssr: false,
});
