unit KUtil;

interface

uses
  Windows, Messages, SysUtils, StrUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, ExtCtrls, StdCtrls, xmldom, XMLIntf, msxmldom,
  XMLDoc,  ShellAPI, Global;

type
  TKUtil = Class

    private
      stText : String;
      stWordCount: Integer;
      stFindString   : String;
      stFindPosition : Integer;

      procedure GetWordCount;
      procedure SetText(const Value: String);

    published

      constructor Create(Text : String);
      function Replace(fromStr, toStr : String) : Integer;
      function FindFirst(search : String) : Integer;
      function FindNext : Integer;
      procedure Split(
        const Delimiter: Char;
        const Strings: TStrings);

      property Text : String
        read stText
        write SetText;

      property WordCount : Integer
        read stWordCount;
  end;



implementation

constructor TKUtil.Create(Text : String);
begin
  stText := Text;
  stFindPosition := 1;
  stFindstring := '';
  GetWordCount;
end;

procedure TKUtil.SetText(const Value: String);
begin
  stText := Value;
  stFindPosition := 1;
  GetWordCount;
end;

procedure TKUtil.GetWordCount;
const
   // Define word separator types that we will recognise
   LF    = #10;
   TAB   = #9;
   CR    = #13;
   BLANK = #32;
var
   WordSeparatorSet : Set of Char;  // We will set on only the above characters
   index  : Integer;     // Used to scan along the string
   inWord : Boolean;     // Indicates whether we are in the middle of a word
begin
  // Turn on the TAB, CR, LF and BLANK characters in our word separator set
  WordSeparatorSet := [LF, TAB, CR, BLANK];

  // Start with 0 words
  stWordCount := 0;

  // Scan the string character by character looking for word separators
  inWord := false;

  for index := 1 to Length(stText) do
  begin
    // Have we found a separator character?
    if stText[index] In WordSeparatorSet
    then
    begin
      // Separator found - have we moved from a word?
      if inWord then Inc(stWordCount);    // Yes - we have ended another word

      // Indicate that we are not in a word anymore
      inWord := false;
    end
    else
      // Separator not found - we are in a word
      inWord := true;
  end;

  // Finally, were we still in a word at the end of the string?
  // if so, we must add one to the word count since we did not
  // meet a separator character.
  if inWord then Inc(stWordCount);
end;

function TKUtil.FindFirst(search: String) : Integer;
begin
  stFindString := search;
  stFindPosition := 1;
  Result := FindNext;
end;

function TKUtil.FindNext: Integer;
var
  index    : Integer;
  findSize : Integer;
begin
  /// Only scan if we have a valid scan string
  if Length(stFindString) = 0
  then Result := -2
  else
  begin
    // Set the search string size
    findSize := Length(stFindString);

    // Set the result to the 'not found' value
    Result := -1;

    // Start the search from where we last left off
    index  := stFindPosition;

    // Scan the string :
    // We check for a match with the first character of the fromStr as we
    // step along the string. Only when the first character matches do we
    // compare the whole string. This is more efficient.
    // We abort the loop if the string is found.
    while (index <= Length(stText)) and (Result < 0) do
    begin
      // Check the first character of the search string
      if stText[index] = stFindString[1] then
      begin
        // Now check the whole string - setting up a loop exit condition if
        // the string matches
        if AnsiMidStr(stText, index, findSize) = stFindString
        then Result := index;
      end;

      // Move along the string
      Inc(index);
    end;

    // Position the next search from where the above leaves off
    // Notice that index gets incremented even with a successful match
    stFindPosition := index
  end;

  // This subroutine will now exit with the established Result value
end;

function TKUtil.Replace(fromStr, toStr: String): Integer;
var
  fromSize, count, index  : Integer;
  newText : String;
  matched : Boolean;
begin
  // Get the size of the from string
  fromSize := Length(fromStr);

  // Start with 0 replacements
  count := 0;

  // We will build the target string in the newText variable
  newText := '';
  index := 1;

  // Scan the string :
  // We check for a match with the first character of the fromStr as we step
  // along the string. Only when the first character matches do we compare
  // the whole string. This is more efficient.
  while index <= Length(stText) do
  begin
    // Indicate no match for this character
    matched := false;

    // Check the first character of the fromStr
    if stText[index] = fromStr[1] then
    begin
      if AnsiMidStr(stText, index, fromSize) = fromStr then
      begin
        // Increment the replace count
        Inc(count);

        // Store the toStr in the target string
        newText := newText + toStr;

        // Move the index past the from string we just matched
        Inc(index, fromSize);

        // Indicate that we have a match
        matched := true;
      end;
    end;

    // if no character match :
    if not matched then
    begin
      // Store the current character in the target string, and
      // then skip to the next source string character
      newText := newText + stText[index];
      Inc(index);
    end;
  end;

  // Copy the newly built string back to stText - as long as we made changes
  if count > 0 then stText := newText;

  // Return the number of replacements made
  Result := count;
end;

procedure TKUtil.Split
   (const Delimiter: Char;
    const Strings: TStrings);
begin
   Assert(Assigned(Strings));
   Strings.Clear;
   Strings.QuoteChar := '|';
   Strings.Delimiter := Delimiter;
   Strings.DelimitedText := stText;
end;

end.
 