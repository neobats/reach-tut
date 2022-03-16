import { loadStdlib } from "@reach-sh/stdlib";
import * as backend from "./build/index.main.mjs";
const stdlib = loadStdlib(process.env);

(async () => {
  const startingBalance = stdlib.parseCurrency(100);
  const accAlice = await stdlib.newTestAccount(startingBalance);
  const accBob = await stdlib.newTestAccount(startingBalance);

  // format some currency up to 4 decimal places
  const format = (monies) => stdlib.formatCurrency(monies, 4);
  // get a participant's balance and display it up to 4 decimal places
  const getBalance = async (who) => format(await stdlib.balanceOf(who));
  const beforeAlice = await getBalance(accAlice);
  const beforeBob = await getBalance(accBob);

  const ctcAlice = accAlice.contract(backend);
  const ctcBob = accBob.contract(backend, ctcAlice.getInfo());

  const HAND = ["Rock", "Paper", "Scissors"];
  const OUTCOME = ["Bob wins", "Draw", "Alice wins"];
  const Player = (Who) => ({
    ...stdlib.hasRandom, // New! allows each participant's Reach code to generate random numbers as necessary.
    getHand: () => {
      const hand = Math.floor(Math.random() * 3);
      console.log(`${Who} played ${HAND[hand]}`);
      return hand;
    },
    seeOutcome: (outcome) => {
      console.log(`${Who} saw outcome ${OUTCOME[outcome]}`);
    },
    informTimeout: () => {
      console.log(`${Who} observed a timeout.`);
    },
  });

  await Promise.all([
    ctcAlice.p.Alice({
      ...Player("Alice"),
      wager: stdlib.parseCurrency(5), // this sets the wager, but it could be pulled from the front end into here.
      deadline: 10, // sets the deadline to 10 blocks. Could be pulled from the front end.
    }),
    ctcBob.p.Bob({
      ...Player("Bob"),
      // turning Bob's acceptWager into an async function due to the wait
      acceptWager: async (amount) => {
        // this if condition is simulating Bob not participating.
        if (Math.random() <= 0.5) {
          for (let i = 0; i < 10; i++) {
            console.log(`*** Bob takes his sweet time...`);
            await stdlib.wait(1); // why we made this async
          }
        } else {
          console.log(`Bob accepts the wager of ${format(amount)}`);
        }
      },
    }),
  ]);

  const afterAlice = await getBalance(accAlice);
  const afterBob = await getBalance(accBob);

  console.log(`Alice went from ${beforeAlice} to ${afterAlice}.`);
  console.log(`Bob went from ${beforeBob} to ${afterBob}.`);
})(); // <-- Don't forget these!
