"reach 0.1";

// same thing as type Player = { ... } in TypeScript
const Player = {
  getHand: Fun([], UInt),
  seeOutcome: Fun([UInt], Null),
};

export const main = Reach.App(() => {
  const Alice = Participant("Alice", {
    ...Player,
  });
  const Bob = Participant("Bob", {
    ...Player,
  });
  init();

  // only means only this participant does the thing in this transaction.
  Alice.only(() => {
    // interact is this object/interface.
    const handAlice = declassify(interact.getHand());
  });
  // somehow..? this handAlice value is known for publication.
  Alice.publish(handAlice);
  commit();

  Bob.only(() => {
    // declassify makes the information public. So, the hand is now
    // "declassified" and no longer secret
    const handBob = declassify(interact.getHand());
  });
  // Bob joins Alice in the application by publishing the value,
  // in this case the hand, to the network.
  Bob.publish(handBob);

  const outcome = (handAlice + (4 - handBob)) % 3;
  // commit to the consensus network. The thing is now on chain.
  commit();

  // enumerate different participants in the transaction
  // to do some thing
  each([Alice, Bob], () => {
    // okay, this scoping actually makes sense...
    interact.seeOutcome(outcome);
  });
});
