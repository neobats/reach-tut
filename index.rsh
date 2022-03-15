"reach 0.1";
// ^ usual reach header

// the hands playable
const [isHand, ROCK, PAPER, SCISSORS] = makeEnum(3);
// the possible outcomes
const [isOutcome, B_WINS, DRAW, A_WINS] = makeEnum(3);

const determineWinner = (handAlice, handBob) => (handAlice + (4 - handBob)) % 3; // fancy maths
//assertions that the outcomes we expect to be true are actually true
assert(determineWinner(ROCK, PAPER) == B_WINS);
assert(determineWinner(PAPER, ROCK) == A_WINS);
assert(determineWinner(ROCK, ROCK) == DRAW);

// an even more powerful assertion...
forall(UInt, (handAlice) =>
  forall(UInt, (handBob) =>
    assert(isOutcome(determineWinner(handAlice, handBob)))
  )
);
forall(UInt, (hand) => assert(determineWinner(hand, hand) == DRAW));
// an awesome quote from the docs:
/*
These examples both use forall, which allows Reach programmers to
quantify over all possible values that might be provided to a part
of their program. You might think that these theorems will take a
very long time to prove, because they have to loop over all the 
billions and billions of possibilities (e.g., Ethereum uses 256-bits
for its unsigned integers) for the bits of handAlice (twice!) and handBob.
In fact, on rudimentary laptops, it takes less than half a second.
That's because Reach uses an advanced symbolic execution engine to
reason about this theorem abstractly without considering individual values.
*/

// define the interface
const Player = {
  // allow each frontend to provide access to random numbers
  ...hasRandom, // new!
  // we use that ^ to protect Alice's hand
  getHand: Fun([], UInt),
  seeOutcome: Fun([UInt], Null),
  // informTimeout: Fun([], Null),
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

  Alice.only(() => {
    const wager = declassify(interact.wager);
    const _handAlice = interact.getHand();
    const [_commitAlice, _saltAlice] = makeCommitment(interact, _handAlice);
    const commitAlice = declassify(_commitAlice); // well this is a rather OOP way to do it...
  });
  Alice.publish(wager, commitAlice).pay(wager);
  commit();

  // assert that Bob cannot know Alice's hand or salt
  unknowable(Bob, Alice(_handAlice, _saltAlice));
  Bob.only(() => {
    interact.acceptWager(wager);
    const handBob = declassify(interact.getHand());
  });
  Bob.publish(handBob).pay(wager);
  commit();

  Alice.only(() => {
    const saltAlice = declassify(_saltAlice);
    const handAlice = declassify(_handAlice);
  });
  Alice.publish(saltAlice, handAlice);
  checkCommitment(commitAlice, saltAlice, handAlice);

  const outcome = determineWinner(handAlice, handBob);
  const [forAlice, forBob] =
    outcome == A_WINS
      ? [2, 0]
      : outcome == B_WINS
      ? [0, 2]
      : /* tie           */ [1, 1];
  transfer(forAlice * wager).to(Alice);
  transfer(forBob * wager).to(Bob);
  commit();

  each([Alice, Bob], () => {
    interact.seeOutcome(outcome);
  });
});
