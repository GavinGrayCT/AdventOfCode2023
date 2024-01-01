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

long[FitKey] countsPerGroup; // group index, from record index
                             //  Input ==> group fits

long[string] countsPerCondRec;

char[] focusCondRec = cast(char[])"?.?#??????";
bool writelnOn = false;

void main()
{
  string answerTextPart1 = "Day x, Part 1:";
  string answerTextPart2 = "Day x, Part 2:";
  ulong answerPart1 = 0;
  ulong answerPart2 = 0;
  // auto startTime = MonoTime.currTime;
  auto pathFilename = "data/thedata.txt";

  // fillInputRecords(pathFilename);
  // answerPart1 = calcPart1(inputRecords);

  fillBigInputRecords(pathFilename);
  auto startTime = MonoTime.currTime;
  answerPart2 = calcPart2_B(inputRecords);

  // Debug
  // writeln(format!"inputRecords: %s"(inputRecords));


  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Calc duration ==> %s usecs", duration.total!"usecs");
  writeln(format!"%s %s"(answerTextPart1, answerPart1));
  writeln(format!"%s %s"(answerTextPart2, answerPart2));

}

// void fillInputRecords(string pathFilename) {
//   inputRecords = [];
//   char[] data = cast(char[])read(pathFilename);

//   writeln(format!"inputRecords.length: %s, data: %s ..."(inputRecords.length, data[0..50]));
//   foreach (line; lineSplitter(data)) {
//     extractData(line);
//   }
// }

void fillBigInputRecords(string pathFilename) {
  inputRecords = [];
  char[] data = cast(char[])read(pathFilename);

  // writeln(format!"inputRecords.length: %s, data: %s ..."(inputRecords.length, data[0..50]));
  inputRecords = getBigInputRecords(data);
}

// long calcPart1(InputRecord[] inputRecords) {
//   writeln("Calc Part 1");
//   long validCount = 0;
//   foreach(i, inputRecord; inputRecords) {
//     writeln(format!"For inputRecord: %s %s"(i, inputRecord.condRec));
//     char[] key = inputRecord.condRec.dup;
//     char[][] arrangements = generateArrangements(inputRecord);
//     // writeln(format!"Arrangements: %s"(arrangements));
//     bool valid = false;
//     long validCountForRecord = 0;
//     foreach (arrangement; arrangements) {
//       valid = checkArrangement(inputRecord, arrangement); 
//       if (valid) {
//         validCountForRecord += 1;
//       }
//     }
//     writeln("\n======================================================================================");
//     writeln(format!"%s valid arrangement(s) for inputRecord: %s, key: %s"(validCountForRecord, inputRecord.condRec, key));
//     writeln("======================================================================================\n");
//     countsPerCondRec[cast(string)key] = validCountForRecord;
//     validCount += validCountForRecord;
//   }
//   return validCount;
// }

// long calcPart2(char[] data) {
//   writeln("Calc Part 2");
//   InputRecord[] bigInputRecords = getBigInputRecords(data);
//   return calcPart1(bigInputRecords);
// }

// long calcPart2_A(InputRecord[] inputRecords) {
//   // writeln("Calc Part 2 A");
//   // char[] data = cast(char[])"???.###????.###????.###????.###????.###";
//   // char[] data = cast(char[])".??..??...?##.?.??..??...?##.?.??..??...?##.?.??..??...?##.?.??..??...?##.";
//   // char[] data = cast(char[])".??..??...?##.";
//   // char[] data = cast(char[])"?###????????";
//   // char[] data = cast(char[])"????.######..#####.?????.######..#####.?????.######..#####.?????.######..#####.?????.######..#####.";
//   // InputRecord aRecord = InputRecord(data, [1,6,5,1,6,5,1,6,5,1,6,5,1,6,5]);
//   char[] data = cast(char[])"?###??????????###??????????###??????????###??????????###????????";
//   InputRecord aRecord = InputRecord(data, [3,2,1,3,2,1,3,2,1,3,2,1,3,2,1]);
//   // char[] data = cast(char[])"?#?#?#?#?#?#?#???#?#?#?#?#?#?#???#?#?#?#?#?#?#???#?#?#?#?#?#?#???#?#?#?#?#?#?#?";
//   // InputRecord aRecord = InputRecord(data, [1,3,1,6,1,3,1,6,1,3,1,6,1,3,1,6,1,3,1,6]);
//   writeln(format!"For inputRecord: %s, groups: %s"(data, aRecord.damList));
//   return findFits(0, 0, aRecord);
// }

long calcPart2_B(InputRecord[] inputRecords) {
  writeln("Calc Part 2 B");
  long total = 0;
  foreach(n, inputRecord; inputRecords) {
    // writelnOn = inputRecord.condRec == focusCondRec? true : false;
    countsPerGroup.clear();
    // writeln(format!"%s For inputRecord: %s, groups: %s"(n, inputRecord.condRec, inputRecord.damList));
    long count = findFits(0, 0, inputRecord);
    // writeln(format!"%s arrangements: %s"(n, count));
    if (writelnOn)
      writeln(format!"%s\ncount: %s, condRec: %s\n%s"("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++",
                                        count, inputRecord.condRec,
                                        "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"));
    // if (cast(string)inputRecord.condRec !in countsPerCondRec) {
    //   throw new Exception(format!"condRec: %s is not in countsPerCondRec"(inputRecord.condRec));
    // } else if (countsPerCondRec[cast(string)inputRecord.condRec] != count) {
    //   // throw new Exception(format!"Differing counts for condRec: %s, %s vs %s"(inputRecord.condRec, countsPerCondRec[cast(string)inputRecord.condRec], count));
    //   if (writelnOn)
    //   writeln(format!"%s Differing counts for condRec: %s, %s vs %s %s"("------------------------------------------------------------------------",
    //                                     inputRecord.condRec, countsPerCondRec[cast(string)inputRecord.condRec], count,
    //                                     "------------------------------------------------------------------------"));
    // }
    total += count;                                       
  }
  return total;
}


long findFits(long groupi, long starti, const InputRecord inputRecord) {
  long endi = 0;
  long spaceReq = 0;
  foreach(long i ; groupi .. inputRecord.damList.length) {
    spaceReq += inputRecord.damList[i] +1; // +1 for trailing dot
    if (writelnOn)
      writeln(format!"i: %s, group: %s, spaceReq: %s, inputRecord.condRec.length: %s"(i, inputRecord.damList[i], spaceReq, inputRecord.condRec.length));
  }
  endi = inputRecord.condRec.length - spaceReq +1 +1;  // remove final . and toi not in loop
  if (writelnOn)
    writeln(format!"findFits in the record for group: %s from starti: %s to endi: %s"(inputRecord.damList[groupi], starti, endi));

  long totalCounts = 0;
  // foreach (fromi; starti .. endi) {  // looping through starting places for group
  long fromi = starti;
  bool foundArrangement = false;
  while ( (fromi < endi) && (!foundArrangement)) {
    FitKey fit = FitKey(groupi, fromi);
    if (fit !in countsPerGroup) {
      countsPerGroup[fit] = 0;
      if (checkFit(fit, inputRecord)) {
        if (writelnOn)
          writeln(format!"Got the fit: %s for broken: %s"(fit, inputRecord.damList[fit.groupi]));
        long nextGroupi = groupi + 1;
        long nextFromi = fromi + inputRecord.damList[fit.groupi] + 1;
        if (nextGroupi < inputRecord.damList.length) {
          long broken = inputRecord.damList[nextGroupi];
          if (writelnOn)
            writeln(format!"Diving. broken: %s, nextGroupi: %s, nextFromi: %s"(broken, nextGroupi, nextFromi));
          countsPerGroup[fit] += findFits(nextGroupi, nextFromi, inputRecord);
        } else {
          countsPerGroup[fit] = 1;
        }
      } else {

      } 
    } else {
      if (writelnOn)
        writeln(format!"Already have fits. fit: %s"(fit));
    }
    fromi += 1;
    totalCounts += countsPerGroup[fit];
    if (writelnOn)
      writeln(format!"Counts: %s for fit: %s. totalCounts: %s"(countsPerGroup[fit], fit, totalCounts));

    // check no unconsumed '#'s on the left of fromi
    long unconsumed = 0;
    foreach (c; inputRecord.condRec[0 .. fromi]) {
      if (c == '#') {unconsumed++;}
    }
    long expConsumed = 0;
    foreach(g; inputRecord.damList[0 .. groupi]) {
      expConsumed += g;
    }
    if (writelnOn)
      writeln(format!"Checking foundArrangement. unconsumed: %s, expConsumed: %s"(unconsumed, expConsumed));
    if (unconsumed > expConsumed) {
      foundArrangement = true;
    }
    if (inputRecord.condRec[fromi -1] == '#') { // More band-aid
      foundArrangement = true;
    }
  }
  if (writelnOn)
      writeln(format!"Jumping out fit. group: %s, groupi: %s, startFromi: %s, totalCounts: %s"(inputRecord.damList[groupi], groupi, starti, totalCounts));
  return totalCounts;
}

bool checkFit(FitKey fit, const InputRecord inputRecord) {
  long fromi = fit.fromi;
  long toi = fit.fromi + inputRecord.damList[fit.groupi];
  long broken = inputRecord.damList[fit.groupi];
  if (writelnOn)
    writeln(format!"checkFit. broken: %s, fromi: %s, toi: %s, rec len: %s"(broken, fromi, toi, inputRecord.condRec.length));
  if (toi < inputRecord.condRec.length) {
    if (!".?".canFind(inputRecord.condRec[toi])) {
      return false;
    }
  }
  if (fromi > 0) {
    if (!".?".canFind(inputRecord.condRec[fromi -1])) {
      return false;
    }

  }
  foreach(ch; inputRecord.condRec[fromi .. toi]) {
    if (!"#?".canFind(ch)) {
      return false;
    }
  }
  if (fit.groupi >= inputRecord.damList.length -1) { // last group
    if (toi < inputRecord.condRec.length) { // chars remaining in condRec
      if (writelnOn)
        writeln(format!"condRec[toi .. $]: %s"(inputRecord.condRec[toi .. $]));
      if (inputRecord.condRec[toi .. $].canFind("#")) { // no fit if # remains
        if (writelnOn)
          writeln(format!"Not a match");
        return false;
      }
    }
  }
  if (writelnOn)
    writeln(format!"Fit found. broken: %s, fromi: %s"(broken, fromi));
  if (writelnOn)
    printFit(fit, inputRecord);
  return true;
}

void printFit(FitKey fit, const InputRecord inputRecord) {
  long fromi = fit.fromi;
  long toi = fit.fromi + inputRecord.damList[fit.groupi];
  long broken = inputRecord.damList[fit.groupi];
  char[] fitChars;
  char[] brokenChars;
  if (fromi > 0) {
    fitChars ~= inputRecord.condRec[fromi -1];
  }
  for (long i = 0; i < broken; i++) {
    fitChars ~= inputRecord.condRec[fromi +i];
    brokenChars ~= '#';
  }
  if (toi < inputRecord.condRec.length -1) {
    fitChars ~= inputRecord.condRec[toi];
  }
  writeln(format!"======================================= broken: %s, brokenChars: %s, fitChars: %s, fromi: %s, condRec: %s"(broken, brokenChars, fitChars, fromi, inputRecord.condRec));
}

// void findAllFits(long start, ref char[] condRec, long[] damList) {
//   while (start >= 0) {
//     start = getFirstFit(start, condRec, damList[0]);
//     if (damList.length > 0) {
//       findAllFits(start, condRec, damList[0 .. $]);
//     } else {
//       break;
//     }
//   }
// }


// long getCounts(InputRecord inputRecord) {
//   writeln(format!"For inputRecord: %s"(inputRecord.condRec));
//   bool done;
//   long nextPos = 0;
//   while (nextPos >= 0) {
//     nextPos = getFirstFit(nextPos, inputRecord.condRec, inputRecord.damList[0]);
//     writeln(format!"nextPos: %s, inputRecord.condRec %s, inputRecord.damList[0]: %s"(nextPos, inputRecord.condRec, inputRecord.damList[0]));
//   }
//   return 0;
// }

// long getFirstFit(long start, char[] condRec, long damQty) {
//   if (start >= condRec.length) {
//     return -1;
//   }
//   long i = start;
//   long d = damQty;
//   while (true) {
//     writeln(format!"start: %s, i: %s, d: %s, char: %s, damQty: %s"(start, i, d, condRec[i], damQty));
//     if ( condRec[i] != '.') {
//       if (condRec[i] == '?') {
//         condRec[i] = 'f';
//       }
//       d -= 1;
//       if (d <= 0) {
//         if (i < condRec.length -1) {
//           if ( condRec[i+1] == '.') { 
//             return i + d +2;
//           } else if ( condRec[i+1] == '?') { 
//             condRec[i+1] = 'g';
//             writeln(format!"Found fit: %s"(condRec[1-damQty .. i]));
//             return i + d +2;
//           }
//           d = damQty;
//         } else {
//           return -1;
//         }
//       }
//     } else {
//       d = damQty;
//     }

//     i++;
//     if (i >= condRec.length) {
//       return -1;
//     }
//   }
// }

void extractData(char[] line) {
  // writeln(format!"Line is: %s"(line));
  InputRecord inputRecord;
  char[][] temp = line.split(' ');
  inputRecord.condRec = temp[0];
  inputRecord.damList = (cast(char[])temp[1]).split(',').map!(d => to!long(d)).array;
  inputRecords ~= inputRecord;
}

InputRecord[] getBigInputRecords(char[] data) {
  // writeln("getBigRecords");
  foreach (line; lineSplitter(data)) {
    extractData(line);
  }
  InputRecord[] bigInputRecords;
  foreach(r, inputRecord; inputRecords) {
    // writeln(format!"For inputRecord: %s %s"(r, inputRecord.condRec));
    InputRecord bigInputRecord;
    for (long i = 0; i < 5; i++) {
      if (i < 4) {
        bigInputRecord.condRec ~= inputRecord.condRec ~ '?';
      } else {
        bigInputRecord.condRec ~= inputRecord.condRec;
      }
      bigInputRecord.damList ~= inputRecord.damList;
    }
    bigInputRecords ~= bigInputRecord;
  }
  return bigInputRecords;
}


// char[][] generateArrangements(InputRecord inputRecord) {
//   char[][] arrangements;
//   char[] anArrangement = inputRecord.condRec;
//   while (true) {
//     long i = anArrangement.indexOf('?');
//     if (i >= 0) {
//       anArrangement[i] = 'f';
//     } else {
//       break; // all ? now f.
//     }
//   }
//   // writeln(format!"For inputRecord: %s, anArrangement: %s"(inputRecord.condRec, anArrangement));

//   while (true) {
//     // writeln(format!"About to add anArrangement: %s"(anArrangement));
//     arrangements ~= anArrangement.dup;
//     // writeln(format!"W1 Arrangements: %s"(arrangements));
//     long i =  0;
//     while (true) {
//       if (anArrangement[i] == 'f') {
//         anArrangement[i] = 't';
//         break;
//       } else if (anArrangement[i] == 't') {
//         anArrangement[i] = 'f';
//       }
//       i += 1;
//       if (i >= anArrangement.length) {
//         break;
//       }
//     }
//     if (i >= anArrangement.length) {
//       break;
//     }
//   }
//   foreach(ref arrangement; arrangements) {
//     for (long i = 0; i < arrangement.length; i++) {
//       if (arrangement[i] == 't') {
//         arrangement[i] = '.';
//       } else if (arrangement[i] == 'f') {
//         arrangement[i] = '#';
//       }
//     }
//   }
//   return arrangements;
// }

// bool checkArrangement(InputRecord inputRecord, char[] arrangement) {
//   // writefln(format!"Checking arrangement: %s against %s"(arrangement, inputRecord.damList));
//   long di, dli, ai = 0;
//   if (inputRecord.damList.length > 0) {
//     di = inputRecord.damList[dli++];
//   }
//   string state = "Expect Either";
//   while (true) {
//     // writefln(format!"Char: %s, State: |%s|  dli: %s, di: %s, ai: %s"(arrangement[ai], state, dli, di, ai));
//     switch (state) {
//       case "Expect Either": {
//         if (arrangement[ai] == '.') {
//           goto case "Got .";
//         } else if (arrangement[ai] == '#') {
//           goto case "Got 1st #";
//         } else {
//           throw new Exception(format!"Illegal character in input");
//         }
//       }
//       case "Got .": {
//         state = "Expect Either";
//         break;
//       }
//       case "Got 1st #": {
//         if (di > 0) {
//           di -= 1;
//           if (di == 0) {
//             if (dli == inputRecord.damList.length) {
//               di = 0;
//               state = "Expect only .s";
//             } else {
//               di = inputRecord.damList[dli++];
//               state = "Expect .";
//             }
//           } else {
//             state = "Expect #";
//           }
//         } else {
//           return false;
//         }
//         break;
//       }
//       case "Expect #": {
//         if (arrangement[ai] == '#') {
//           if (di > 1) {
//             di -= 1; 
//             state = "Expect #"; // no change
//           } else if (di == 1) {
//             if (dli == inputRecord.damList.length) {
//               di = 0;
//               state = "Expect only .s";
//             } else {
//               di = inputRecord.damList[dli++];
//               state = "Expect .";
//             }
//           } else {
//             throw new Exception(format!"Unexpected else condition");
//           }
//         } else {
//           return false;
//         }
//         break;
//       }
//       case "Expect .": {
//         if (arrangement[ai] == '.') {
//           state = "Expect Either";
//         } else {
//           return false;
//         }
//         break;
//       }
//       case "Expect only .s": {
//         if (arrangement[ai] == '.') {
//           state = "Expect only .s"; // no change
//         } else {
//           return false;
//         }
//         break;
//       }
//       default: {
//         throw new Exception(format!"Illegal state");
//       }

//     }
//     // writefln(format!"State: |%s| , dli: %s, di: %s, ai: %s"(state, dli, di, ai));
//     ai += 1;
//     if (ai >= arrangement.length) {
//       if (dli >= inputRecord.damList.length) {
//         if (state == "Expect only .s") {
//           writeln("\n======================================================================================");
//           writefln(format!"Valid arrangement: %s"(arrangement));
//           writeln("======================================================================================\n");
//           return true;
//         }
//         return false;
//       }
//       return false;
//     }
//   }
//   writeln("Dropping out of loop");
//   return false;
// }
