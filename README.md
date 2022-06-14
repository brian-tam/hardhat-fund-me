Mostly will be the same as the course material, but changed a little bit from the FundMe Staging test.

I was not able to run the test successfully. 

Problem:
During the test, it said the endingBalance does not equal to 0. And on the etherscan, the withdraw function showed: txn receipt status fail.

Code:
```
  FundMe
    1) allows people to fund and withdraw

  0 passing (31s)
  1 failing

  1) FundMe
       allows people to fund and withdraw:

      AssertionError: expected '50000000000000000' to equal '0'
      + expected - actual

      -50000000000000000
      +0
```
Solution:
I noticed that the fund() function and the withdraw() function, on the etherscan, they are on the same block. So I think this is the problem that causes the failing. So I let both of the response wait for 1 block after calling the function from the contracts. Luckily it worked!

```
  FundMe
    ✓ allows people to fund and withdraw (29450566 gas)


  1 passing (11m)

✨  Done in 638.57s.
```