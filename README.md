# Pascal to Print source beautifier

## Project Summary

`PtoP` is a Pascal source beautifier predating Tree Sitter and Language Server Protocol. While many Language Servers provide code formatting, I plan to stick with `PtoP`. It's late 2025 and Language Server support for Pascal is weak and fragmented; I see a few incomplete repos on GitHub that aren't very active and appear to be forks of each other. I've never written an LSP and I don't have an urge to do so (yet).

`PtoP` appears to be complete but it wasn't written to be integrated into an editor and I have found a few bugs in my testing. This project will address those issues.

I copied the source for `PtoP` from `FPCSource/utils` (specifically the mirror on GitHub as of September 2025). I don't know if my changes will be worth merging with the master sources. If I don't get around to doing a merge and anyone finds this code useful, I explicitly give *anyone* the right to merge this work into the live Free Pascal project source (which I believe is hosted on GitLab).

## Bugs and Changes Needed

These are wordy, but I've included my testing notes as I've analyzed them.

### Changes and Enhancements

1. Provide an option to replace named files for input and output with `stdin` and `stdout`. This will allow `PtoP` to be used from editors such as Helix, Vim, and Emacs.

2. Allow blocks of code to be protected from formatting by use of in source markers (as `clangfmt` does).

### Bugs

1. Comment blocks delimited by braces {} sometimes format incorrectly.

   1. Multi-line blocks with comment text on the same line as the open brace get an extra leading blank line. Subsequent runs continue to add more and more blank lines. This does not occur on single line block comments, nor on multi-line blocks where the only thing on the first line is the open brace.

   2. In at least one instance I see a multi-line brace block comment losing its indent.

   Some notes and observations:

   - It's always a newline before.
   - Prior lines of code have no effect.
   - Indent level has no effect.
   - Placing the opening brace on an otherwise empty line inhibits this behavior. The location of the closing brace doesn't matter.

The "double" comment, (* *) instead of { } works correctly but other than a minor difference in the configuration that did not seem to fix anything in testing. The code for all three types of comments, single block {}, double block (* *), and Delphi style line comments '//' follows different path, but they all look the same to me.

2. Indenting of Try/Finally and Try/Except appears to be broken, but I might misunderstand the syntax.

   A block of Try/Finally/End over outdents (deindent is how the code refers to it). So:

   ```pascal
   Begin
       { code }
       Try
         blah;
       Finally
         blarg;
       End;
       { more code }
   End.
   ```

   Formats as:

   ```pascal
   Begin
       { code }
       Try
         blah;
       Finally
         blarg;
   End;
   { more code }
   End.
   ```

   Is no End needed after the Finally? The configuration tables in `PtoP` seem to expect the End.

   I've made various tweaks to the configuration file, but nothing helps. More debugging is needed. I would expect Finally and Except to behave like Else but the configurations are different:

   ```text
   finally=crbefore,dindent,inbytab,crafter,lower
   else=crbefore,dindonkey,inbytab,lower
   * Tested with and without changes to end.

   The mssing crafter makes sense, but the dindonkey vs dindent
   is worth looking at further.

   Another idea is that [end]=.....try,finally,except... and maybe
   it shouldn't include try? dunno. if,then,else are there.
   * See above on finally/else
   * alo tried adding keys for try, no joy.
   ```

## History and Genealogy

There are many Pascal source formatters around the web. Many are rewrites of each other. The only clear statement of origin for `PtoP` is from the Free Pascal documentation:

> `ptop` is a source beautifier written by Peter Grogono based on the ancient pretty-printer by Ledgard, Hueras, and Singer, modernized by the Free Pascal team (objects, streams, configurability etc).
>
> This configurability, and the thorough bottom-up design are the advantages of this program over the diverse Turbo Pascal source beautifiers on e.g. SIMTEL.

If I can find Grogono's original code I'll include it as a historical reference.

## License

The Free Pascal Compiler package is licensed under GPL v2, the run-time files are licensed under modified LGPL. Both can be found in the original repository's LICENSE file.

There was no explicit license file for `PtoP` in the utils directory, but it refers to the COPYING.FPC file. This file no longer exists and seems to have been replaced by the repository's LICENSE file.

My additions/corrections are all public domain. The source in the original repository is all marked as being under the Gnu Lesser Public License. I've copied the licensing files from the source to LICENSE in this repository.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Troy Brumley\
BlameTroi@gmail.com\
So let it be written...\
...so let it be done
