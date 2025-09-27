{$mode objfpc}
{$H+}
Program PtoP;
{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2002 by Michael Van Canneyt, member of
    the Free Pascal development team

    Pascal pretty print program

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{ bug -- Every curly brace enclosed block comment that contains multiple
         lines is gaining an extra blank line in front of it's opening
         brace. This does not happen for the digraph form of comments,
         nor for curly brace comments that fit on one line.

         Some oddities:

         - It's always a new line before.
         - Prior lines of code have no effect.
         - Indent level has no effect.
         - Placing the opening brace on an otherwise empty line
           inhibits this behavior. The location of the closing brace
           doesn't matter.

         These are defined as open and close comment in the config file
         and the digraph form is defined differently. I'm testing the
         removal of the differences.

  bug -- When indenting try/finally/end, the end is mis-indented. It
         aligns with the start of the block holding the try.

         I see the keywords in ptopu, so it's not just that these are
         not understood. Two ideas:

         - Try finally end, and try except end, but you can not have
           try except finally end (or finally except). Make sure the
           code recognizes this. ... end misindents.

         - A possible mistake in the configuration file.

         Research: I would expect finally and except to behave in a
         manner similar to else. The definitions are different:

         finally=crbefore,dindent,inbytab,crafter,lower
         else=crbefore,dindonkey,inbytab,lower
         * Tested with and without changes to end.

         The mssing crafter makes sense, but the dindonkey vs dindent
         is worth looking at further.

         Another idea is that [end]=.....try,finally,except... and maybe
         it shouldn't include try? dunno. if,then,else are there.
         * See above on finally/else
         * alo tried adding keys for try, no joy.

  enh -- Add support for using stdin and stdout so that ptop can be
         invoked from Helix and similar editors. }

Uses SysUtils,Classes,PtoPu,CustApp, bufstream;

ResourceString
  Version   = 'Version 1.2';
  ATitle     = 'PToP';
  Copyright = 'Copyright (c) 1999-2005 by the Free Pascal Development Team';
  SErrNoInputOutput = 'No input and output file given';
  
Type
  TPToP = Class(TCustomApplication)
  Private
    Infilename,
    OutFileName,
    ConfigFile : String;
    BeVerbose : Boolean;
    TheIndent,
    TheBufSize,
    TheLineSize : Integer;
    Procedure Usage(ECode : Word);
    Procedure GenOpts;
    Procedure ProcessOpts;
    Procedure DoVerbose(Sender : TObject; Const Msg : String);
  Public
    Procedure DoRun; override;
  end;


Procedure TPToP.DoVerbose(Sender : TObject; Const Msg : String);

begin
  Writeln(StdErr,Msg);
end;

Procedure TPToP.Usage(ECode : Word);

begin
  Writeln ('ptop : Usage : ');
  Writeln ('ptop [-v] [-i indent] [-b bufsize ][-c optsfile][-l linesize] infile outfile');
  Writeln ('     converts infile to outfile.');
  Writeln ('     -c : read options from optsfile');
  Writeln ('     -i : Set number of indent spaces.');
  Writeln ('     -l : Set maximum output linesize.');
  Writeln ('     -b : Use buffers of size bufsize');
  Writeln ('     -v : be verbose');
  writeln ('ptop -g ofile');
  writeln ('     generate default options file');
  Writeln ('ptop -h : This help');
  halt(Ecode);
end;

Procedure TPToP.Genopts;

Var S : TFileStream;

begin
  S:=TFileStream.Create(ConfigFile,fmCreate);
  Try
    GeneratecfgFile(S);
  Finally
    S.Free;
  end;
end;

Procedure TPToP.ProcessOpts;

Var
  S : String;
begin
  { Set defaults }
  Infilename:='';
  OutFileName:='';
  ConfigFile:='';
  TheIndent:=2;
  TheBufSize:=255;
  TheLineSize:=DefLineSize;
  BeVerbose:=False;
  S:=CheckOptions('icglbhv','');
  If (S<>'') then
    begin
    Writeln(stderr,S);
    Usage(1);
    end;
  if HasOption('h') then
    usage(0);
  TheIndent:=StrToIntDef(GetOptionValue('i',''),2);
  TheBufSize:=StrToIntDef(GetOptionValue('b',''),255);
  TheLineSize:=StrToIntDef(GetOptionValue('l',''),DefLineSize);
  If HasOption('g') then
    begin
    ConfigFile:=GetOptionValue('g','');
    GenOpts;
    halt(0);
    end;
  ConfigFile:=GetOptionValue('c','');
  BeVerbose:=HasOption('v');
  If (ParamCount>1) then
    begin
    InFileName:=paramstr(ParamCount-1);
    OutFilename:=Paramstr(ParamCount);
    end;
end; { Of ProcessOpts }

Procedure TPToP.DoRun;

Var
  F,InS,OutS,cfgS : TSTream;
  PPrinter : TPrettyPrinter;

begin
  ProcessOpts;
  if BeVerbose then
    begin
    writeln(Title+' '+Version);
    writeln(Copyright);
    writeln('infile...: ', InFileName);
    writeln('outfile..: ', OutFileName);
    writeln('config...: ', ConfigFile);
    Writeln;
    end;
  If (Length(InfileName)=0) or (Length(OutFileName)=0) Then
    begin
    Writeln(stderr,SErrNoInputOutput);
    Usage(1);
    end;
  Ins:=TMemoryStream.Create;
  try
    F:=TFileStream.Create(InFileName,fmOpenRead);
    Try
      Ins.CopyFrom(F,0);
      Ins.Position:=0;
    Finally
      F.Free;
    end;
    OutS:=TwriteBufStream.Create(TFileStream.Create(OutFileName,fmCreate));
    Try
      If ConfigFile<>'' then
        CfgS:=TFileStream.Create(ConfigFile,fmOpenRead)
      else
        CfgS:=Nil;
      try
        PPrinter:=TPrettyPrinter.Create;
        Try
          PPrinter.Indent:=TheIndent;
          PPrinter.LineSize:=TheLineSize;
          PPrinter.Source:=Ins;
          PPrinter.Dest:=OutS;
          PPrinter.Config:=CfgS;
          If BeVerbose then
            PPrinter.OnVerbose:=@DoVerbose;
          PPrinter.PrettyPrint;
        Finally
          FreeAndNil(PPrinter);
        end;
      Finally
        FreeAndNil(CfgS);
      end;
    Finally
      FreeAndNil(OutS);
    end;
  Finally
    FreeAndNil(Ins);
  end;
  Terminate;
end;

begin
  With TPToP.Create(Nil) do
    Try
      Title:= ATitle;
      StopOnException:=True;
      Initialize;
      Run;
    Finally
      Free;
    end;
end.
