# OpenZeppelin Ethernaut CTF Solutions | Foundry

This repo solves all Ethernaut CTFs using Foundry framework. Each CTF has its solution file, comments to explain the solution, and logging results in the cmd for better understanding. Feel free to mark a new issue if there is something not clear, or if there is an error in the solution.

## Getting Started

- All Ethernaut CTFs smart contracts exist in `/src` folder.
- Solutions are existed in `/script` folder.
- The CTF solution file has the same name as CTF contract file name adding `.s` to it.
- If the CTF challenge is `src/Fallback.sol`, the solution will be `script/Fallback.s.sol`.
- The solution script deploys a new instance for the CTF smart contract, then cracks it.

## Installation

It is better to have a version of `forge` equal to or higher than the version of `forge` that is being used in the repo, to avoid having any errors.

_Repo forge version: forge 0.2.0 (same as cast, anvil, and chisel)_

To update Foundry to the latest version you can write:

```
foundryup
```

---

1. Clone the git repository.

```
git clone https://github.com/Al-Qa-qa/ethernaut-solutions-foundry
```

2. Compile smart contracts, and build them.

```
forge install
forge build
```

3. Run forge script for any challenge.

```
forge script script/Fallback.s.sol
```

## Solutions

We discuss every solution as an X (twitter) thread, you can check them out for deep understanding.
|CTF Challenge Name|Solution|
|-------------|--------|
|Fallback|[https://twitter.com/Al_Qa_qa/status/1725932182479196277](https://twitter.com/Al_Qa_qa/status/1725932182479196277)|
|Fal1out|[https://twitter.com/Al_Qa_qa/status/1726271394403737651](https://twitter.com/Al_Qa_qa/status/1726271394403737651)|
|CoinFlip|[https://twitter.com/Al_Qa_qa/status/1726646608354574730](https://twitter.com/Al_Qa_qa/status/1726646608354574730)|
|Telephone|[https://twitter.com/Al_Qa_qa/status/1726997223224021411](https://twitter.com/Al_Qa_qa/status/1726997223224021411)|
|Token|[https://twitter.com/Al_Qa_qa/status/1727362365673631958](https://twitter.com/Al_Qa_qa/status/1727362365673631958)|
|Delegation|[https://twitter.com/Al_Qa_qa/status/1727729481903726644](https://twitter.com/Al_Qa_qa/status/1727729481903726644)|
|Force|[https://twitter.com/Al_Qa_qa/status/1728092529210351734](https://twitter.com/Al_Qa_qa/status/1728092529210351734)|
|Vault|[https://twitter.com/Al_Qa_qa/status/1728472291103711566](https://twitter.com/Al_Qa_qa/status/1728472291103711566)|
|King|[https://twitter.com/Al_Qa_qa/status/1729178725009555741](https://twitter.com/Al_Qa_qa/status/1729178725009555741)|
|Reentrance|[https://twitter.com/Al_Qa_qa/status/1729530569371824521](https://twitter.com/Al_Qa_qa/status/1729530569371824521)|
|Elevator|[https://twitter.com/Al_Qa_qa/status/1729895020910580201](https://twitter.com/Al_Qa_qa/status/1729895020910580201)|
|Privacy|[https://twitter.com/Al_Qa_qa/status/1730259669279445159](https://twitter.com/Al_Qa_qa/status/1730259669279445159)|
|GatekeeperOne|[https://twitter.com/Al_Qa_qa/status/1730653184392093907](https://twitter.com/Al_Qa_qa/status/1730653184392093907)|
|GatekeeperTwo|[https://twitter.com/Al_Qa_qa/status/1730985699472490561](https://twitter.com/Al_Qa_qa/status/1730985699472490561)|
|NaughtCoin|[https://twitter.com/Al_Qa_qa/status/1731349380345614370](https://twitter.com/Al_Qa_qa/status/1731349380345614370)|
|Preservation|[https://twitter.com/Al_Qa_qa/status/1732797381706404072](https://twitter.com/Al_Qa_qa/status/1732797381706404072)|
|Recovery|[https://twitter.com/Al_Qa_qa/status/1733186855745561056](https://twitter.com/Al_Qa_qa/status/1733186855745561056)|
|MagicNumber|[https://twitter.com/Al_Qa_qa/status/1733552067677933732](https://twitter.com/Al_Qa_qa/status/1733552067677933732)|
|Alien Codex|[https://twitter.com/Al_Qa_qa/status/1733898573295526100](https://twitter.com/Al_Qa_qa/status/1733898573295526100)|
|Denial|[https://twitter.com/Al_Qa_qa/status/1734251088453267722](https://twitter.com/Al_Qa_qa/status/1734251088453267722)|
|Shop|[https://twitter.com/Al_Qa_qa/status/1734613240431235091](https://twitter.com/Al_Qa_qa/status/1734613240431235091)|
|DEX|[https://twitter.com/Al_Qa_qa/status/1735009587567223154](https://twitter.com/Al_Qa_qa/status/1735009587567223154)|
|DEX 2|[https://twitter.com/Al_Qa_qa/status/1735697068298006684](https://twitter.com/Al_Qa_qa/status/1735697068298006684)|
|Puzzle Wallet|[https://twitter.com/Al_Qa_qa/status/1736819045691715628](https://twitter.com/Al_Qa_qa/status/1736819045691715628)|
|Motor bike|[https://twitter.com/Al_Qa_qa/status/1737191622582919377](https://twitter.com/Al_Qa_qa/status/1737191622582919377)|
|DoubleEntryPoint|[https://twitter.com/Al_Qa_qa/status/1737866163726565586](https://twitter.com/Al_Qa_qa/status/1737866163726565586)|
|GoodSamaritan|[https://twitter.com/Al_Qa_qa/status/1738246983578427589](https://twitter.com/Al_Qa_qa/status/1738246983578427589)|
|GatekeeperThree|[https://twitter.com/Al_Qa_qa/status/1738617504195338450](https://twitter.com/Al_Qa_qa/status/1738617504195338450)|
|Switch|[https://twitter.com/Al_Qa_qa/status/1739006383930937479](https://twitter.com/Al_Qa_qa/status/1739006383930937479)|

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
