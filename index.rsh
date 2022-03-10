"reach 0.1";

// same thing as type Player = { ... } in TypeScript... and then creating one
const Player = {
  getHand: Fun([], UInt),
  seeOutcome: Fun([UInt], Null),
};

export const main = Reach.App(() => {
  const Alice = Participant("Alice", {
    ...Player,
    wager: UInt,
  });
  const Bob = Participant("Bob", {
    ...Player,
    acceptWager: Fun([UInt], Null),
  });
  init();

  // only means only this participant does the thing in this transaction.
  Alice.only(() => {
    // interact is this object/interface.
    const wager = declassify(interact.wager);
    const handAlice = declassify(interact.getHand());
  });
  // somehow..? this handAlice value is known for publication.
  // I guess what things you publish is what makes them available for use outside the participant's actions.
  Alice.publish(wager, handAlice).pay(wager);
  commit();

  Bob.only(() => {
    interact.acceptWager(wager);
    // declassify makes the information public. So, the hand is now
    // "declassified" and no longer secret
    const handBob = declassify(interact.getHand());
  });
  // Bob joins Alice in the application by publishing the value,
  // in this case the hand, to the network.
  Bob.publish(handBob).pay(wager);

  const outcome = (handAlice + (4 - handBob)) % 3;
  const [forAlice, forBob] =
    outcome == 2 ? [2, 0] : outcome == 0 ? [0, 2] : /* tie */ [1, 1];

  transfer(forAlice * wager).to(Alice);
  transfer(forBob * wager).to(Bob);
  // commit to the consensus network. The thing is now on chain.
  commit();

  // enumerate different participants in the transaction
  // to do some thing
  each([Alice, Bob], () => {
    // okay, this scoping actually makes sense...
    interact.seeOutcome(outcome);
  });
});
