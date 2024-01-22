import std.stdio;
import core.time;
import std.conv;
import std.format;
import std.file;
import std.algorithm;
import std.ascii;
import std.string;

struct Pattern {
  char[][] rows;
}
Pattern[] patterns;

void main()
{
  string answerTextPart1 = "Day x, Part 1:";
  string answerTextPart2 = "Day x, Part 2:";
  ulong answerPart1 = 0;
  ulong answerPart2 = 0;
  auto startTime = MonoTime.currTime;
  auto pathFilename = "data/smalldata.txt";
  fillPatternsFromInputData(pathFilename);

  // Debug
  foreach (i, pattern; patterns) {
    writeln(format!"%s\n%s"(i, pattern));
  }

  answerPart1 = computeReflectionScores();

  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Calc duration ==> %s usecs", duration.total!"usecs");
  writeln(format!"%s %s"(answerTextPart1, answerPart1));
  writeln(format!"%s %s"(answerTextPart2, answerPart2));
  throw new Exception(format!"Exception example");

}

void fillPatternsFromInputData(string pathFilename) {
  string data = cast(string)read(pathFilename);
  Pattern pattern;
  foreach (line; lineSplitter(data)) {
    if (line.length > 0) {
      pattern.rows ~= cast(char[])line;
    } else {
      patterns ~= pattern;
      pattern = Pattern();
    }
  }
  patterns ~= pattern;  // If not last blank line
}

long computeReflectionScores() {
  long reflectionScore = 0;
  foreach(i, pattern; patterns) {
    bool foundRowReflection = false;
    for (long r = 1; r < pattern.rows.length; r++) {
      if (checkRowReflect(pattern, r)) {
        reflectionScore += r*100;
        foundRowReflection = true;
        break;
      }
    }
    if (!foundRowReflection) {
      for (long c = 1; c < pattern.rows[0].length; c++) {
        if (checkColReflect(pattern, c)) {
          reflectionScore += c;
          break;
        }
      }
    }
  }
  return reflectionScore;
}

bool checkRowReflect(ref Pattern pattern, long beforeRow) {
  long i = beforeRow -1;
  long j = beforeRow;
  writeln(format!"#rows: %s, r: %s  i,j: %s,%s"(pattern.rows.length, beforeRow, i, j));
  while ( (i >= 0) && (j < pattern.rows.length)) {
    for (long k = 0; k < pattern.rows[i].length; k++) {
      if (pattern.rows[i][k] != pattern.rows[j][k]) {
        return false;
      }
    }
    i--; j++;
  }
  writefln("Reflection found at before row %s", beforeRow);
  return true;
}


bool checkColReflect(ref Pattern pattern, long beforeCol) {
  long i = beforeCol -1;
  long j = beforeCol;
  writeln(format!"#cols: %s, c: %s  i,j: %s,%s"(pattern.rows[0].length, beforeCol, i, j));
  while ( (i >= 0) && (j < pattern.rows[0].length)) {
    for (long k = 0; k < pattern.rows.length; k++) {
      if (pattern.rows[k][i] != pattern.rows[k][j]) {
        return false;
      }
    }
    i--; j++;
  }
  writefln("Reflection found at before col %s", beforeCol);
  return true;
}
