# Notes

- I re cloned the repository from GitHub to get rid of CRLF noise. Git wasn't actually making the changes in my prior working copy for some reason even though I changed and committed.

- I removed default options from ptopu.pp for open/close comment. The brace style fails but the double character '(* *)' version works correctly when formatting and it has no default options set in the code.

- Digging in to the try/finally/end problem I finally saw that the blocks between the keywords do not have to be compound (begin/end if multi-statement). I retested with multiple statements and no begin/end and the error still occurs.

  From my skim of the code, there's a stack of some sort that might be at issue here. Maybe the try and finally aren't put on the stack correctly and the unwind for the end fails?
