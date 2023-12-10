import std.stdio;
import core.time;
import std.conv;
import std.format;
import std.file;
import std.algorithm;
import std.ascii;
import std.string;
import std.array;

long[][] lines;

void main()
{
  string answerTextPart1 = "Day 9, Part 1:";
  string answerTextPart2 = "Day 9, Part 2:";
  long answerPart1 = 0;
  long answerPart2 = 0;
  auto startTime = MonoTime.currTime;
  auto pathFilename = "data/thedata.txt";
  string data = cast(string)read(pathFilename);

  int i = 0;
  foreach (line; lineSplitter(data)) {
    extractData(i++, line);
  }

  long[][][] allLinesDiffs = getHistories(lines);
  foreach(lineDiffs; allLinesDiffs) {
    long aSum = 0;
    for(long j = lineDiffs.length -1; j >= 0; j--) {
      long[]lineDiff = lineDiffs[j];
      writeln(format!"Getting answer part1, lineDiff: %s, long: %s, asum: %s, next: %s"(lineDiff, lineDiff[$-1], aSum, lineDiff[$-1] + aSum));
      answerPart1 += lineDiff[$-1];
      aSum += lineDiff[$-1];
    }
    writeln(format!"aSum: %s"(aSum));
  }

  // Debug
  //writeln(format!"Data is: %s"(lines));
  //writeln(format!"allLinesDiffs is: %s"(allLinesDiffs));

  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Calc duration ==> %s usecs", duration.total!"usecs");
  writeln(format!"%s %s"(answerTextPart1, answerPart1));
  writeln(format!"%s %s"(answerTextPart2, answerPart2));
}

void extractData(int i, string line) {
  writeln(format!"%s Line is: %s"(i, line));
  lines ~= splitter(line).array.map!(a => to!long(a)).array;
}

long [][][] getHistories(long[][] lines){
  long[][][] allLinesDiffs;
  foreach(line; lines) {
    allLinesDiffs ~= getHistory(line);
  }
  return allLinesDiffs;
}

long[][] getHistory(long[] line) {
  // writeln(format!"getHistory - line: %s"(line));
  long[][] lineDiffs;
  lineDiffs ~= line;
  long sumDiffs = 1;
  while (sumDiffs != 0) {
    // writeln(format!"while - line: %s, line.length: %s"(line, line.length));
    sumDiffs = 0;
    long[] aDiff = [];
    for (int i = 0; i < (line.length -1); i++) {
      sumDiffs += line[i +1] - line[i];
      aDiff ~= line[i +1] - line[i];
    }
    lineDiffs ~= aDiff;
    line = aDiff;
    // writeln(format!"while end - line: %s, aDiff: %s"(line, aDiff));
  }
  return lineDiffs;
}