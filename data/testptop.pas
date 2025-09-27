{ streams and stdio }
{$MODE OBJFPC}
{ This is a multiline block comment at the head of the program, it starts
  with one blank line before and after. How will it be changed by ptop?

  And is that change correct? }
Program StreamTest;
Uses 
classes, sysutils;
Var 
  rdr: TStream;
  lst: TStream;
  f: TStream;
  fni: string;
  fno: string;
  l: AnsiString;
  count: integer;
Begin
  (* The following tests multiline brace blocks inbetwist code with no
     blank lines before or after. *)
  If false Then
    { multiline one
      before begin }
    Begin
    { multiline one
      after begin }
      writeln('false');
    { multiline two
      before end }
    End
    { multiline two
      after end }
  Else
    Begin
      { and what about
        here? }
      writeln('true');
    End;
  (* The following tests multiline brace blocks inbetwist code with one
     blank line before or after. *)
  If false Then
    { multiline one
      before begin }
    Begin
    { multiline one
      after begin }
      writeln('false');
    { multiline two
      before end }
    End;
    { multiline two
      after end }
(* .... *)
{
a three line with nothing else on the brace lines ... 
}
(* ... *)
{ and another multiple line comment
  block that takes up some
  space and is followed by yet ahother multi line comment
  block. }
{ P1 = input file, p2 = output file. If omitted, stdin and stdout are
  used. Both stdin and stdount can be used as parameters, so
  "cmd infile stdout". }
  If ParamCount = 2 Then
    { an oddity?
      or perhaps not? }
    Begin
      { and another multiple line comment
        block that takes up some
        space and is followed by yet ahother multi line comment
        block. }
      fni := ParamStr(1);
      fno := ParamStr(2);
    End
  Else
    Begin
      fni := 'stdin';
      fno := 'stdout';
    End;
    { another block comment spanning lines
      and lines and lines. }
  Try
    Begin
      writeln('blarg');
      writeln('blarg');
    End
  Finally
    Begin
      writeln('blip');
      writeln('blip');
    End
  End;
  Try
    If fni = 'stdin' Then
      f := THandleStream.Create(StdInputHandle)
    Else
      f := TFileStream.Create(fni, fmOpenRead);
  Finally
    f.free
  End;
  rdr := TMemoryStream.Create;
  rdr.CopyFrom(f, 0);
  rdr.Position := 0;
  f.free;
  If fno = 'stdout' Then
    lst := THandleStream.Create(StdOutputHandle)
  Else
    lst := TFileStream.Create(fno, fmCreate);
  While rdr.Position < rdr.Size Do
    Begin
      l := rdr.ReadAnsiString;
      count := count + 1;
      lst.WriteAnsiString(l)
    End;
  rdr.Free;
  lst.Free;
  writeln(stderr, count);
End.
