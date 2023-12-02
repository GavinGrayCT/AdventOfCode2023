import std.range;
import std.stdio;
import std.ascii;
import std.conv;
import core.time;
import std.algorithm;

// Simple, easy to understand;
// Tolerant of invalid input
void main() {
  foreach(i, textDigit; textDigits) {
    textDigitToDigit[textDigit] = toChars(i)[0];
  }
  auto file = File("data/thedata.txt"); // Open for reading

  auto startTime = MonoTime.currTime;

  auto range = file.byLine();
  ulong theSum = 0;
  foreach (line; range) {
    theSum += getLinesNumber(line);
  }

  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Hello Duration ==> %s usecs", duration.total!"usecs");
  writefln("The sum of the embedded numbers is %s", theSum);
}

ulong getLinesNumber(const char[] line) {
  ulong containedNumber = 0;
  char a = 0 , b = 0;
  bool gotADigit = false;
  for (int i = 0; i < line.length; i++) {
    if (!gotADigit) {
      if (line[i].isDigit)  { // Get first digit
        a = line[i];
        gotADigit = true;
        // writefln("1st digit: %s", a);
      } else {
        foreach(ref textDigit; textDigits) {
          // writefln("Looking for 1st in |%s|. textDigit: |%s|, i: %s, textDigit.length: %s, line.length: %s, line: %s",
          //          line[i..min(i + textDigit.length, line.length)], textDigit, i, textDigit.length, line.length, line);
          if (textDigit == line[i..min(i + textDigit.length, line.length)]) {
            a = textDigitToDigit[textDigit];
            gotADigit = true;
            // writefln("1st textDigit: %s (%s) (value:%s)", textDigit, a, textDigitToDigit[textDigit]);
            break;
          }
        }
      }
    }
    if (gotADigit) {
      if (line[i].isDigit) { // b will be last digit
        b = line[i];
        // writefln("2nd digit: %s", b);
      } else {
          foreach(textDigit; textDigits) {
            // writefln("Looking for 2nd in %s. textDigit: %s, i: %s, textDigit.length: %s, line.length: %s, line: %s",
            //         line[i..min(i + textDigit.length, line.length)], textDigit, i, textDigit.length, line.length, line);
            if (textDigit == line[i..min(i + textDigit.length, line.length)]) {
              b = textDigitToDigit[textDigit];
              // writefln("2nd textDigit: %s (%s)", textDigit, b);
              break;
            }
          }

      }
    }
  }
  // writefln("a: %s (%02X), b: %s (%02X)", a, a, b, b);
  char[] numberStr;
  numberStr ~= a;
  numberStr ~= b;
  if (gotADigit) {
    containedNumber =to!ulong(numberStr, 10);
    // writefln("numberStr: %s, containedNumber: %s", numberStr, containedNumber);
  } else {
    // writefln("No digits in: %s", line);
    containedNumber = 0;
  }
  return containedNumber;
}

string[] textDigits = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"];
char[string] textDigitToDigit;
