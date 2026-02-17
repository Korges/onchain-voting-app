import { ConnectButton } from "@rainbow-me/rainbowkit";

export default function Header() {
  return (
    //<nav className="px-8 py-4.5 border-b-[1px] border-zinc-100 flex flex-row justify-between items-center bg-white xl:min-h-[77px]">
    <nav className="px-8 py-4.5 border-b-[1px] border-zinc-100 flex flex-row justify-between items-center bg-white xl:min-h-[77px]">
      <div className="flex items-center gap-2.5 md:gap-6">
         <a href="/" className="flex items-center gap-1 text-zinc-800">
                    <h1 className="font-bold text-2xl hidden md:block">TSender</h1>
                </a>
      </div>
      <h3 className="italic text-left hidden text-zinc-500 lg:block">
        Onchain Voting App
      </h3>
      <div className="flex items-center gap-4">
        <ConnectButton />
      </div>
    </nav>
  );
}
