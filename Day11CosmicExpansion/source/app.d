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

struct Empty {
  bool[] emptyColFlag;
  bool[] emptyRowFlag;
}

struct Scale {
  long[] row;
  long[] col;
}

void main()
{
  string answerTextPart1 = "Day x, Part 1:";
  string answerTextPart2 = "Day x, Part 2:";
  ulong answerPart1 = 0;
  ulong answerPart2 = 0;
  auto startTime = MonoTime.currTime;
  auto pathFilename = "data/thedata.txt";
  string data = cast(string)read(pathFilename);

  answerPart1 = part1Calc(data);
  writeln(format!"\n=========================================================================================================\nPart 2");
  answerPart2 = part2Calc(data);
  

  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Calc duration ==> %s usecs", duration.total!"usecs");
  writeln(format!"%s %s"(answerTextPart1, answerPart1));
  writeln(format!"%s %s"(answerTextPart2, answerPart2));
  // throw new Exception(format!"Exception example");
}

// =========================================================================================================
// Part 1 answer = 10165598
long part1Calc(string data){
  Empty empty;

  long l = 0;
  foreach (line; lineSplitter(data)) {
    extractData(l++, line);
  }

  // Debug
  writeln(format!"Unexpanded grid");
  foreach(line; grid) {
    writeln(format!"%-(%s%)"(cast(char[])line));
  }

  // Get empty rows and columns
  empty = getEmptyRowsAndCols();
  // Debug
  foreach(rI, row; grid) {
      if (empty.emptyRowFlag[rI] == true) {
      writeln(format!"Found row empty: %s"(rI));
    }
  }

  for (long i = 0; i < empty.emptyColFlag.length; i++) {
    if (empty.emptyColFlag[i] == true) {
      writeln(format!"Found col empty: %s"(i));
    }
  }

  // Expansion: Insert Rows 
  for(long rI = grid.length -1; rI > -1; rI--) {
    if (empty.emptyRowFlag[rI]) {
      char[] newRow;
      newRow = cast(char[])replicate("o", grid[rI].length);
      writeln(format!"Inserting blank row: %s"(rI));
      grid.insertInPlace(rI +1, newRow);
    }
  }

  // Expansion: Insert Columns 
  foreach(ref row; grid) {
    for(long cI = empty.emptyColFlag.length -1; cI > -1; cI--) {
      if (empty.emptyColFlag[cI] == true) {
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
  countGalaxies();

  // Sum distances
  long sumDistances = 0;
  for (int i = 0; i < galaxys.length -1; i++) {
    for (int j = i; j < galaxys.length; j++) {
      sumDistances += abs(galaxys[i].row - galaxys[j].row) + abs(galaxys[i].col - galaxys[j].col);
    }
  }
  writeln(format!"sumDistances: %s"(sumDistances));
  return sumDistances;
}

// =========================================================================================================
// Part 2 answer = 678728808158
long part2Calc(string data){
  Empty empty;
  grid = [][];
  galaxys = [];

  long l = 0;
  foreach (line; lineSplitter(data)) {
    extractData(l++, line);
  }

  // Debug
  writeln(format!"Unexpanded grid");
  foreach(line; grid) {
    writeln(format!"%-(%s%)"(cast(char[])line));
  }

  // Get empty rows and columns
  empty = getEmptyRowsAndCols();
  // Debug
  foreach(rI, row; grid) {
      if (empty.emptyRowFlag[rI] == true) {
      writeln(format!"Found row empty: %s"(rI));
    }
  }

  for (long i = 0; i < empty.emptyColFlag.length; i++) {
    if (empty.emptyColFlag[i] == true) {
      writeln(format!"Found col empty: %s"(i));
    }
  }

  // Expansion: Get Scale
  Scale scale = getScale(grid, empty);

  // Debug
  writeln(format!"Expanded grid; rows");
  writeln(format!"%-(,%s%)"(cast(long[])scale.row));
  writeln(format!"Expanded grid; cols");
  writeln(format!"%-(,%s%)"(cast(long[])scale.col));

  // Count galaxies
  countGalaxies();

  // Sum distances
  long sumDistances = 0;
  for (int i = 0; i < galaxys.length; i++) {
    for (int j = i+1; j < galaxys.length; j++) {
      // writeln(format!"i: %s, j: %s"(i, j));
      // Galaxy a, b;
      // writeln(format!"galaxys[j].col: %s"(galaxys[j].col));
      // a.row = galaxys[i].row + scale.row[galaxys[i].row];
      // a.col = galaxys[i].col + scale.col[galaxys[i].col];
      // b.row = galaxys[j].row + scale.row[galaxys[j].row];
      // b.col = galaxys[j].col + scale.col[galaxys[j].col];
      // writeln(format!"a: %s, b: %s"(a, b));
      // writeln(format!"galaxys.length: %s, grid length: %s, grid width: %s, scale.row len: %s, scale.col len: %s"(galaxys.length, grid.length, grid[0].length, scale.row.length, scale.col.length));
      // long x1, y1, x2, y2;
      // x1 = galaxys[i].row + scale.row[galaxys[i].row];
      // x2 = galaxys[j].row + scale.row[galaxys[j].row];
      // writeln(format!"x1: %s, x2: %s, distance: %s"(x1, x2, abs(x1 - x2)));
      // y1 = galaxys[i].col + scale.col[galaxys[i].col];
      // y2 = galaxys[j].col + scale.col[galaxys[j].col];
      // writeln(format!"y1: %s, y2: %s, distance: %s"(y1, y2, abs(y1 - y2)));
      long distance = abs( (scale.row[galaxys[i].row]) - (scale.row[galaxys[j].row])) +
                      abs( (scale.col[galaxys[i].col]) - (scale.col[galaxys[j].col]) );
      sumDistances += distance;
      // writeln(format!"Distance between 2 galaxies is: %s"(distance));

    }
  }
  writeln(format!"sumDistances: %s"(sumDistances));
  return sumDistances;
}


void extractData(long l, string line) {
  writeln(format!"Line %s is: %s"(l, line));
  grid ~= cast(char[])line;
}

Empty getEmptyRowsAndCols() {
  Empty empty;
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
  empty.emptyRowFlag = emptyRowFlag;
  empty.emptyColFlag = emptyColFlag;
  return empty;
}

void   countGalaxies() {
  foreach(rI, row; grid) {
    // writeln(format!"Making galaxys. nr cols: %s"(row.length));
    foreach(cI, col; row) {
      if (col == '#') {
        // writeln(format!"Making galaxys. galaxys.length: %s, rI: %s, cI: %s, nr rows: %s, nr cols: %s"(galaxys.length, rI, cI, grid.length, row.length));
        galaxys ~= Galaxy(rI, cI);
      }
    }
  }
  // for (long i = 0; i < galaxys.length; i++) {
  //   writeln(format!"Galaxys: %s, %s"(i, galaxys[i]));
  // }
  writeln(format!"Nr Galaxys: %s"(galaxys.length));
}

Scale getScale(char[][] grid, Empty empty) {
  Scale scale;
  long[] rowScale;
  long currentScale = 0;
  for (long rI = 0; rI < grid.length; rI++) {
    if (empty.emptyRowFlag[rI]) {
      currentScale += 999_999;
    }
    rowScale ~= rI + currentScale;
  }
  long[] colScale;
  currentScale = 0;
  for (long cI = 0; cI < grid[0].length; cI++) {
    if (empty.emptyColFlag[cI]) {
      currentScale += 999_999;
    }
    colScale ~= cI + currentScale;
  }
  scale.row = rowScale;
  scale.col = colScale;
  writefln(format!"Scales: %s"(scale));
  return scale;
}
