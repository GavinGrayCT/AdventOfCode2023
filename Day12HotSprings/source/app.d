import std.stdio;
import core.time;
import std.conv;
import std.format;
import std.file;
import std.algorithm;
import std.ascii;
import std.string;
import std.array;

InputRecord[] inputRecords;

struct InputRecord {   // ???.### 1,1,3
  char[] condRec; // ???.###
  long[] damList; // 1,1,3
}

struct FitKey {
  long groupi;
  long fromi;
}

struct Fit {
  FitKey fitKey;
  const InputRecord inputRecord;
  char[] currentCondRec;
  Fit* nextGroupFit;
  long count;
}

long[FitKey] countsPerGroup; // group index, from record index
                          //  Input ==> arrangements accumulative count

void main()
{
  string answerTextPart1 = "Day x, Part 1:";
  string answerTextPart2 = "Day x, Part 2:";
  ulong answerPart1 = 0;
  ulong answerPart2 = 0;
  auto startTime = MonoTime.currTime;
  auto pathFilename = "data/smalldata.txt";
  char[] data = cast(char[])read(pathFilename);

  answerPart1 = calcPart1(data, records);
  answerPart2 = calcPart2_A(data);

  // Debug
  // writeln(format!"records: %s"(records));


  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Calc duration ==> %s usecs", duration.total!"usecs");
  writeln(format!"%s %s"(answerTextPart1, answerPart1));
  writeln(format!"%s %s"(answerTextPart2, answerPart2));

}

  long calcPart1(char[] data, Record[] records) {
    writeln("Calc Part 1");
    foreach (line; lineSplitter(data)) {
      extractData(line);
    }
    long validCount = 0;
    foreach(i, record; records) {
      writeln(format!"For record: %s %s"(i, record.condRec));
      char[][] arrangements = generateArrangements(record);
      // writeln(format!"Arrangements: %s"(arrangements));
      bool valid = false;
      long validCountForRecord = 0;
      foreach (arrangement; arrangements) {
        valid = checkArrangement(record, arrangement); 
        if (valid) {
          validCountForRecord += 1;
        }
      }
      writeln("\n======================================================================================");
      writeln(format!"%s valid arrangement(s) for record: %s"(validCountForRecord, record.condRec));
      writeln("======================================================================================\n");
      validCount += validCountForRecord;
    }
    return validCount;
  }

long calcPart2(char[] data) {
  writeln("Calc Part 2");
  Record[] bigRecords = getBigRecords(data);
  return calcPart1(data, bigRecords);
}

long calcPart2_A(char[] data) {
  writeln("Calc Part 2");
  Record[] bigRecords = getBigRecords(data);
  // long counts = getCounts(bigRecords[0]);
  findAllFits(0, bigRecords[0].condRec, bigRecords[0].damList);
  return 0;
}

void findAllFits(long start, ref char[] condRec, long[] damList) {
  while (start >= 0) {
    start = getFirstFit(start, condRec, damList[0]);
    if (damList.length > 0) {
      findAllFits(start, condRec, damList[0 .. $]);
    } else {
      break;
    }
  }
}


long getCounts(Record record) {
  writeln(format!"For record: %s"(record.condRec));
  bool done;
  long nextPos = 0;
  while (nextPos >= 0) {
    nextPos = getFirstFit(nextPos, record.condRec, record.damList[0]);
    writeln(format!"nextPos: %s, record.condRec %s, record.damList[0]: %s"(nextPos, record.condRec, record.damList[0]));
  }
  return 0;
}

long getFirstFit(long start, char[] condRec, long damQty) {
  if (start >= condRec.length) {
    return -1;
  }
  long i = start;
  long d = damQty;
  while (true) {
    writeln(format!"start: %s, i: %s, d: %s, char: %s, damQty: %s"(start, i, d, condRec[i], damQty));
    if ( condRec[i] != '.') {
      if (condRec[i] == '?') {
        condRec[i] = 'f';
      }
      d -= 1;
      if (d <= 0) {
        if (i < condRec.length -1) {
          if ( condRec[i+1] == '.') { 
            return i + d +2;
          } else if ( condRec[i+1] == '?') { 
            condRec[i+1] = 'g';
            writeln(format!"Found fit: %s"(condRec[1-damQty .. i]));
            return i + d +2;
          }
          d = damQty;
        } else {
          return -1;
        }
      }
    } else {
      d = damQty;
    }

    i++;
    if (i >= condRec.length) {
      return -1;
    }
  }
}

void findFits(ref Fit fit) {
  for (long groupi = fit.fitKey.groupi; groupi < fit.inputRecord.damList.length; groupi++) {
    long count = checkFit(fit);
    if (count > 0) {
      FitKey nextFitKey = FitKey(groupi +1, fit.fitKey.fromi + fit.inputRecord.damList[groupi]);
      fit.nextGroupFit = new Fit()
    }
  }
}

void extractData(char[] line) {
  writeln(format!"Line is: %s"(line));
  Record record;
  char[][] temp = line.split(' ');
  record.condRec = temp[0];
  record.damList = (cast(char[])temp[1]).split(',').map!(d => to!long(d)).array;
  records ~= record;
}

Record[] getBigRecords(char[] data) {
  writeln("getBigRecords");
  foreach (line; lineSplitter(data)) {
    extractData(line);
  }
  Record[] bigRecords;
  foreach(r, record; records) {
    writeln(format!"For record: %s %s"(r, record.condRec));
    Record bigRecord;
    for (long i = 0; i < 5; i++) {
      bigRecord.condRec ~= record.condRec ~ '?';
      bigRecord.damList ~= record.damList;
    }
    bigRecords ~= bigRecord;
  }
  return bigRecords;
}


char[][] generateArrangements(Record record) {
  char[][] arrangements;
  char[] anArrangement = record.condRec;
  while (true) {
    long i = anArrangement.indexOf('?');
    if (i >= 0) {
      anArrangement[i] = 'f';
    } else {
      break; // all ? now f.
    }
  }
  // writeln(format!"For record: %s, anArrangement: %s"(record.condRec, anArrangement));

  while (true) {
    // writeln(format!"About to add anArrangement: %s"(anArrangement));
    arrangements ~= anArrangement.dup;
    // writeln(format!"W1 Arrangements: %s"(arrangements));
    long i =  0;
    while (true) {
      if (anArrangement[i] == 'f') {
        anArrangement[i] = 't';
        break;
      } else if (anArrangement[i] == 't') {
        anArrangement[i] = 'f';
      }
      i += 1;
      if (i >= anArrangement.length) {
        break;
      }
    }
    if (i >= anArrangement.length) {
      break;
    }
  }
  foreach(ref arrangement; arrangements) {
    for (long i = 0; i < arrangement.length; i++) {
      if (arrangement[i] == 't') {
        arrangement[i] = '.';
      } else if (arrangement[i] == 'f') {
        arrangement[i] = '#';
      }
    }
  }
  return arrangements;
}

bool checkArrangement(Record record, char[] arrangement) {
  // writefln(format!"Checking arrangement: %s against %s"(arrangement, record.damList));
  long di, dli, ai = 0;
  if (record.damList.length > 0) {
    di = record.damList[dli++];
  }
  string state = "Expect Either";
  while (true) {
    // writefln(format!"Char: %s, State: |%s|  dli: %s, di: %s, ai: %s"(arrangement[ai], state, dli, di, ai));
    switch (state) {
      case "Expect Either": {
        if (arrangement[ai] == '.') {
          goto case "Got .";
        } else if (arrangement[ai] == '#') {
          goto case "Got 1st #";
        } else {
          throw new Exception(format!"Illegal character in input");
        }
      }
      case "Got .": {
        state = "Expect Either";
        break;
      }
      case "Got 1st #": {
        if (di > 0) {
          di -= 1;
          if (di == 0) {
            if (dli == record.damList.length) {
              di = 0;
              state = "Expect only .s";
            } else {
              di = record.damList[dli++];
              state = "Expect .";
            }
          } else {
            state = "Expect #";
          }
        } else {
          return false;
        }
        break;
      }
      case "Expect #": {
        if (arrangement[ai] == '#') {
          if (di > 1) {
            di -= 1; 
            state = "Expect #"; // no change
          } else if (di == 1) {
            if (dli == record.damList.length) {
              di = 0;
              state = "Expect only .s";
            } else {
              di = record.damList[dli++];
              state = "Expect .";
            }
          } else {
            throw new Exception(format!"Unexpected else condition");
          }
        } else {
          return false;
        }
        break;
      }
      case "Expect .": {
        if (arrangement[ai] == '.') {
          state = "Expect Either";
        } else {
          return false;
        }
        break;
      }
      case "Expect only .s": {
        if (arrangement[ai] == '.') {
          state = "Expect only .s"; // no change
        } else {
          return false;
        }
        break;
      }
      default: {
        throw new Exception(format!"Illegal state");
      }

    }
    // writefln(format!"State: |%s| , dli: %s, di: %s, ai: %s"(state, dli, di, ai));
    ai += 1;
    if (ai >= arrangement.length) {
      if (dli >= record.damList.length) {
        if (state == "Expect only .s") {
          writeln("\n======================================================================================");
          writefln(format!"Valid arrangement: %s"(arrangement));
          writeln("======================================================================================\n");
          return true;
        }
        return false;
      }
      return false;
    }
  }
  writeln("Dropping out of loop");
  return false;
}
