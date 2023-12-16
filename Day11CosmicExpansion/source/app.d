import std.stdio;
import core.time;
import std.conv;
import std.format;
import std.file;
import std.algorithm;
import std.ascii;
import std.string;
import std.array;
import std.math;

char[][] grid;

struct Galaxy{
  long row;
  long col;
}

Galaxy[] galaxys;

// Part 1 answer = 10165598
void main()
{
  string answerTextPart1 = "Day x, Part 1:";
  string answerTextPart2 = "Day x, Part 2:";
  ulong answerPart1 = 0;
  ulong answerPart2 = 0;
  auto startTime = MonoTime.currTime;
  auto pathFilename = "data/thedata.txt";
  string data = cast(string)read(pathFilename);

  foreach (word; lineSplitter(data)) {
    extractData(word);
  }

  // Debug
  writeln(format!"Unexpanded grid");
  foreach(line; grid) {
    writeln(format!"%-(%s%)"(cast(char[])line));
  }

  // Expand
  bool[] emptyColFlag;
  bool[] emptyRowFlag;
  emptyColFlag.length = grid[0].length;
  foreach(ref flag; emptyColFlag) { flag = true;}
  emptyRowFlag.length = grid.length;
  foreach(rI, row; grid) {
    emptyRowFlag[rI] = true;
    foreach(cI, col; row) {
      if (col == '#') {
        emptyColFlag[cI] = false;
        emptyRowFlag[rI] = false;
      }
    }
  }

  // Debug
  foreach(rI, row; grid) {
      if (emptyRowFlag[rI] == true) {
      writeln(format!"Found row empty: %s"(rI));
    }
  }

  for (long i = 0; i < emptyColFlag.length; i++) {
    if (emptyColFlag[i] == true) {
      writeln(format!"Found col empty: %s"(i));
    }
  }

  // Expansion: Insert Rows 
  for(long rI = grid.length -1; rI > -1; rI--) {
    if (emptyRowFlag[rI]) {
      char[] newRow;
      newRow = cast(char[])replicate("o", grid[rI].length);
      writeln(format!"Inserting blank row: %s"(rI));
      grid.insertInPlace(rI +1, newRow);
    }
  }

  // Expansion: Insert Columns 
  foreach(ref row; grid) {
    for(long cI = emptyColFlag.length -1; cI > -1; cI--) {
      if (emptyColFlag[cI] == true) {
        row.insertInPlace(cI +1, '0');
      }
    }
  }

  // Debug
  writeln(format!"Expanded grid");
  foreach(line; grid) {
    writeln(format!"%-(%s%)"(cast(char[])line));
  }

  // Count galaxies
  foreach(rI, row; grid) {
    foreach(cI, col; row) {
      if (col == '#') {
        galaxys ~= Galaxy(rI, cI);
      }
    }
  }

  // Sum distances
  long sumDistances = 0;
  for (int i = 0; i < galaxys.length -1; i++) {
    for (int j = i; j < galaxys.length; j++) {
      sumDistances += abs(galaxys[i].row - galaxys[j].row) + abs(galaxys[i].col - galaxys[j].col);
    }
  }
  writeln(format!"sumDistances: %s"(sumDistances));

  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Calc duration ==> %s usecs", duration.total!"usecs");
  writeln(format!"%s %s"(answerTextPart1, answerPart1));
  writeln(format!"%s %s"(answerTextPart2, answerPart2));
  // throw new Exception(format!"Exception example");
}

void extractData(string line) {
  writeln(format!"Line is: %s"(line));
  grid ~= cast(char[])line;
}

