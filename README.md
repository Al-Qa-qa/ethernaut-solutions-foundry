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

- **SEPOLIA_RPC_URL**: your alchemy sepolia RPC, or you can put a public RPC.
- **PRIVATE_KEY**: Your first wallet private key prefixed by `0x`.
- **PRIVATE_KEY_2**: Your second wallet private key prefixed by `0x`.
- **MY_ADDRESS**: The public address of the first wallet.
- **MY_ADDRESS_2**: The public address of the second wallet.
- **ETHERSCAN_KEY**: Your etherscan API key, you need it in order to verify the contract.

## Solutions
All the solutions are provided in the `/scripts` folder.

We will add solutions for each CTF as a thread in X (Twitter), once the solution for a certain CTF is on X, we will reference it here.

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
