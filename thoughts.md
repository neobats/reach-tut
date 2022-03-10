# Some thoughts around using Reach for the first time

While this is JS syntax, this is definitely _not_ JS.  
By comparison, Node is JS. It feels like JS when you write it, and the only major difference is the API.

But Reach has some different rules. Scope works differently.
Take the following snippet, for example:

```js
Bob.only(() => {
  // a value determined in local scope
  const handBob = declassify(interact.getHand());
});
// now added to the chain... but referenced outside local scope
Bob.publish(handBob);
// available outside scope
const outcome = (handAlice + (4 - handBob)) % 3;
```

## TypeScript

I haven't used it yet, but apparently one can use the `@reach-sh/stdlib` in TypeScript.
That sounds appealing, especially given that in `rsh` files, one creates
types/interfaces regularly.
