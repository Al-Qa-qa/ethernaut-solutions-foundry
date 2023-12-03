# OpenZeppelin Ethernaut CTF Solutions | Foundry

This repo solves all Ethernaut CTFs using Foundry framework. Each CTF has its own solution file, comments to explain the solution, and logging results in the cmd for better understanding. Feel free to contact us if there is something not clear, or if there is an error in the solution.

## Getting Started

- All Ethernaut CTFs smart contracts exist in `/src` folder.
- Solutions are existed in `/script` folder.
- The solution script deploys a new instance for the CTF smart contract, then cracks it.

## Installation

1. Clone the git repository.

```
git clone https://github.com/Al-Qa-qa/ethernaut-solutions-foundry
```

2. Compile smart contracts, and build them.

```
forge build
```

3. Create `.env` file, and copy the data in the `.env.sample` in it.

## Setup

In order to run the scripts (solutions), you need to fill in the data in the `.env` file, here is what you need to add for each variable in the `.env` file.

- `SEPOLIA_RPC_URL`: your alchemy sepolia RPC, or you can put a public RPC.
- `PRIVATE_KEY`: Your first wallet private key prefixed by `0x`.
- `PRIVATE_KEY_2`: Your second wallet private key prefixed by `0x`.
- `MY_ADDRESS`: The public address of the first wallet. -` MY_ADDRESS_2`: The public address of the second wallet.
- `ETHERSCAN_KEY`: Your etherscan API key, you need it in order to verify the contract.

## Solutions

All the solutions are provided in the `/scripts` folder.

We discuss every solution as an X (twitter) thread, you can check them out for deep understanding.

1. Fallback: [https://twitter.com/Al_Qa_qa/status/1725932182479196277](https://twitter.com/Al_Qa_qa/status/1725932182479196277)
2. Fal1out: [https://twitter.com/Al_Qa_qa/status/1726271394403737651](https://twitter.com/Al_Qa_qa/status/1726271394403737651)
3. CoinFlip: [https://twitter.com/Al_Qa_qa/status/1726646608354574730](https://twitter.com/Al_Qa_qa/status/1726646608354574730)
4. Telephone: [https://twitter.com/Al_Qa_qa/status/1726997223224021411](https://twitter.com/Al_Qa_qa/status/1726997223224021411)
5. Token: [https://twitter.com/Al_Qa_qa/status/1727362365673631958](https://twitter.com/Al_Qa_qa/status/1727362365673631958)
6. Delegation: [https://twitter.com/Al_Qa_qa/status/1727729481903726644](https://twitter.com/Al_Qa_qa/status/1727729481903726644)
7. Force: [https://twitter.com/Al_Qa_qa/status/1728092529210351734](https://twitter.com/Al_Qa_qa/status/1728092529210351734)
8. Vault: [https://twitter.com/Al_Qa_qa/status/1728472291103711566](https://twitter.com/Al_Qa_qa/status/1728472291103711566)
9. King: [https://twitter.com/Al_Qa_qa/status/1729178725009555741](https://twitter.com/Al_Qa_qa/status/1729178725009555741)
10. Reentrance: [https://twitter.com/Al_Qa_qa/status/1729530569371824521](https://twitter.com/Al_Qa_qa/status/1729530569371824521)
11. Elevator: [https://twitter.com/Al_Qa_qa/status/1729895020910580201](https://twitter.com/Al_Qa_qa/status/1729895020910580201)
12. Privacy: [https://twitter.com/Al_Qa_qa/status/1730259669279445159](https://twitter.com/Al_Qa_qa/status/1730259669279445159)
13. GatekeeperOne: [https://twitter.com/Al_Qa_qa/status/1730653184392093907](https://twitter.com/Al_Qa_qa/status/1730653184392093907)
14. GatekeeperTwo: [https://twitter.com/Al_Qa_qa/status/1730985699472490561](https://twitter.com/Al_Qa_qa/status/1730985699472490561)
15. NaughtCoin: [https://twitter.com/Al_Qa_qa/status/1731349380345614370](https://twitter.com/Al_Qa_qa/status/1731349380345614370)

## License

This project is under the MIT License. See `LICENSE` for more information.

## Contact

Al-Qa'qa' - [@Al_Qa_qa](https://twitter.com/Al_Qa_qa) - alqaqa.fighter@gmail.com

Project Link: [https://github.com/Al-Qa-qa/ethernaut-solutions-foundary](https://github.com/Al-Qa-qa/ethernaut-solutions-foundary)

## Acknowledgments

Here are some of the services and websites that we used to make this project.

We would like to apologize if we used a free package or service and forgot to mention it.

- [OpenZeppelin](https://www.openzeppelin.com/)
- [Ethernaut](https://ethernaut.openzeppelin.com/)
- [Foundary](https://book.getfoundry.sh/)
