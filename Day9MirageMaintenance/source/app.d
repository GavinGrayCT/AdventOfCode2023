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
    writeln(format!"Getting answer part1, lineDiff: %s"(lineDiffs));
    long next = 0;
    for(long j = lineDiffs.length -2; j >=0; j--) {
      long[] lineDiff = lineDiffs[j];
      next = lineDiff[0] - next;
      writeln(format!"j: %s, lineDiff: %s, long: %s, next: %s"(j, lineDiff, lineDiff[0], next));
    }
    writeln(format!"aSum: %s"(next));
    answerPart2 += next;
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
  while (true) {
    // writeln(format!"while - line: %s, line.length: %s"(line, line.length));
    bool allZeroes = true;
    long[] aDiff = [];
    for (int i = 0; i < (line.length -1); i++) {
      aDiff ~= line[i +1] - line[i];
      if ( (line[i +1] - line[i]) != 0) {
        allZeroes = false;
      }
    }
    lineDiffs ~= aDiff;
    line = aDiff;
    // writeln(format!"while end - line: %s, aDiff: %s"(line, aDiff));
    if (allZeroes) { break;}
  }
  return lineDiffs;
}