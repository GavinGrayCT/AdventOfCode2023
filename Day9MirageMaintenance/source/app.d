import std.stdio;
import core.time;
import std.conv;
import std.format;
import std.file;
import std.algorithm;
import std.ascii;
import std.string;
import std.array;

ulong[][] lines;

void main()
{
  string answerTextPart1 = "Day x, Part 1:";
  string answerTextPart2 = "Day x, Part 2:";
  ulong answerPart1 = 0;
  ulong answerPart2 = 0;
  auto startTime = MonoTime.currTime;
  auto pathFilename = "data/smalldata.txt";
  string data = cast(string)read(pathFilename);

  foreach (line; lineSplitter(data)) {
    extractData(line);
  }

  getHistories(lines);

  // Debug
  writeln(format!"Data is: %s"(lines));

  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Calc duration ==> %s usecs", duration.total!"usecs");
  writeln(format!"%s %s"(answerTextPart1, answerPart1));
  writeln(format!"%s %s"(answerTextPart2, answerPart2));
}

void extractData(string line) {
  writeln(format!"Line is: %s"(line));
  lines ~= splitter(line).array.map!(a => to!ulong(a)).array;
}

void getHistories(ulong[][] lines){
  ulong[][] diffs;
  ulong historiesSum = 0;
  foreach(line; lines) {
    getHistory(line);
  }
}

void getHistory(ulong[] line) {
  writeln(format!"A line: %s"(line));
}