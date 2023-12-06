import std.stdio;
import core.time;
import std.conv;
import std.format;
import std.file;
import std.algorithm;
import std.ascii;

struct Race {
  ulong duration;
  ulong recordDistance;
  ulong recordRuns;
}

Race[] races;

void main()
{
  auto startTime = MonoTime.currTime;
  auto pathFilename = "data/thedatapart2.txt";
  string data = cast(string)read(pathFilename);

  foreach (word; splitter(data)) {
    extractData(word);
  }

  // Debug
  write("Time: ");
  foreach(aRace; races) {
    write(format!"%s "(aRace.duration));
  }
  write("\nDistance: ");
  foreach(aRace; races) {
    write(format!"%s "(aRace.recordDistance));
  }
  writeln;

ulong recordsproduct = getPart1RecordsProduct(races);


  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Calc duration ==> %s usecs", duration.total!"usecs");
  writeln(format!"Records Product for input: %s, is: %s"(pathFilename, recordsproduct));
  writeln(format!"... part 2: %s"("Not yet"));
}

string state = "ready_for_Time:";
Race aRace = Race(0,0, 0);
ulong raceNr = 0;
void extractData(string word) {
  writeln(format!"Word is: %s"(word));
  switch (state) {
    case "ready_for_Time:": {
      if (word == "Time:") {
        state = "get_durations";
      } else {
        throw new Exception(format!"Expected 'Time:', found: |%s| in data"(word));
      }
      break;
    }
    case "get_durations": {
      if (word[0].isDigit) {
        aRace.duration = word.to!ulong;
        races ~= aRace;
        aRace = Race(0, 0, 0);
      } else {
        if (word == "Distance:") {
          state = "get_distances";
        } else {
          throw new Exception(format!"Expected 'Distance:', found: |%s| in data"(word));
        }
      }
      break;
    }
    case "get_distances": {
      if (word[0].isDigit) {
        races[raceNr++].recordDistance = word.to!ulong;
      } else {
          throw new Exception(format!"Got unexpected: |%s| in data"(word));
      }
      break;
    }
    default: {
      throw new Exception(format!"Got unexpected state: |%s|"(state));
    }
  }
}

ulong getPart1RecordsProduct(Race[] races) {
  ulong record = 0;
  foreach(race; races) {
    ulong nrRecords = getNrRaceRecords(race);
    record = ((record == 0)? nrRecords : record * nrRecords);
  }
  return record;
}

ulong getNrRaceRecords(Race race) {
  ulong nrRecords = 0;
  foreach(t; 0..race.duration) {
    nrRecords += ((getDistance(t, race.duration) > race.recordDistance)? 1: 0);
  }
  return nrRecords;
}

ulong getDistance(ulong chargingTime, ulong totalTime) {
  ulong distance = chargingTime * (totalTime - chargingTime);
  //writeln(format!"chargingTime: %s, totalTime: %s, distance: %s"(chargingTime, totalTime, distance));
  return distance;
}

