import std.range, std.stdio;
import std.ascii;
import std.conv;
import core.time;

// Simple, easy to understand;
// Tolerant of invalid input
void main() {
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
  foreach(c; line) {
    if ( (!gotADigit) && (c.isDigit) ) { // Get first digit
      a = c;
      gotADigit = true;
    }
    if (c.isDigit) { // b will be last digit
      b = c;
      gotADigit = true;
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
    writefln("No digits in: %s", line);
    containedNumber = 0;
  }
  return containedNumber;
}