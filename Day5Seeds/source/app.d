import std.stdio;
import core.time;
import std.conv;
import std.format;
import std.file;
import std.algorithm;
import std.ascii;

ulong[] seeds;
ulong[][] seedToSoilMap;
ulong[][] soilToFertilizerMap;
ulong[][] fertilizerToWaterMap;
ulong[][] waterToLightMap;
ulong[][] lightToTemperatureMap;
ulong[][] temperatureToHumidityMap;
ulong[][] humidityToLocationMap;

void main()
{
  auto startTime = MonoTime.currTime;
  auto pathFilename = "data/thedata.txt"; // Open for reading
  string data = cast(string)read(pathFilename);

  foreach (word; splitter(data)) {
    process(word);
  }

  // Debug
  writeln(format!"seeds: %s"(seeds));
  writeln(format!"seedToSoilMap: %s"(seedToSoilMap));
  writeln(format!"soilToFertilizerMap: %s"(soilToFertilizerMap));
  writeln(format!"fertilizerToWaterMap: %s"(fertilizerToWaterMap));
  writeln(format!"waterToLightMap: %s"(waterToLightMap));
  writeln(format!"lightToTemperatureMap: %s"(lightToTemperatureMap));
  writeln(format!"temperatureToHumidityMap: %s"(temperatureToHumidityMap));
  writeln(format!"humidityToLocationMap: %s"(humidityToLocationMap));

  ulong minLocation = ulong.max;
  foreach(seed; seeds) {
    ulong soil = findMapped(seed, seedToSoilMap);
    ulong fertilizer = findMapped(soil, soilToFertilizerMap);
    ulong water = findMapped(fertilizer, fertilizerToWaterMap);
    ulong light = findMapped(water, waterToLightMap);
    ulong temperature = findMapped(light, lightToTemperatureMap);
    ulong humidity = findMapped(temperature, temperatureToHumidityMap);
    ulong location = findMapped(humidity, humidityToLocationMap);
    writeln(format!"seed: %s, soil: %s, fertilizer: %s, water: %s, light: %s, temperature: %s, humidity: %s, location: %s"
                   (seed, soil, fertilizer, water, light, temperature, humidity, location));
    minLocation = min(location, minLocation);
  }

  ulong minLocationPart2 = ulong.max;
  for (ulong i = 0; i < seeds.length; i = i +2) {
    writeln(format!"seed from: %s, len: %s, minLocationPart2: %s"(seeds[i], seeds[i+1], minLocationPart2));
    for (ulong seed = seeds[i]; seed < seeds[i] + seeds[i+1]; seed++) {
      ulong soil = findMapped(seed, seedToSoilMap);
      ulong fertilizer = findMapped(soil, soilToFertilizerMap);
      ulong water = findMapped(fertilizer, fertilizerToWaterMap);
      ulong light = findMapped(water, waterToLightMap);
      ulong temperature = findMapped(light, lightToTemperatureMap);
      ulong humidity = findMapped(temperature, temperatureToHumidityMap);
      ulong location = findMapped(humidity, humidityToLocationMap);
      minLocationPart2 = min(location, minLocationPart2);
      if (minLocationPart2 == 0) {break;}
      // writeln(format!"seed: %s, soil: %s, fertilizer: %s, water: %s, light: %s, temperature: %s, humidity: %s, location: %s"
      //              (seed, soil, fertilizer, water, light, temperature, humidity, location));
    }
  }


  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Calc duration ==> %s usecs", duration.total!"usecs");
  writeln(format!"lowest location number part 1: %s"(minLocation));
  writeln(format!"lowest location number part 2: %s"(minLocationPart2));
}

string state = "ready_for_keyword";
ulong[] triplet;
void process(string word) {
  writeln(format!"Word is: %s"(word));
  switch (state) {
    case "ready_for_keyword": {
      switch (word) {
        case "seeds:": {
          state = "getting_seeds";
          break;
        }
        default: {
          throw new Exception("Unexpected keyword");
        }
      }
      break;
    }
    case "getting_seeds": {
      if (word[0].isDigit) {
        seeds ~= word.to!ulong;
      } else {
        state = word;
      }
      break;
    }
    case "seed-to-soil": {
      processMapInput(seedToSoilMap, word, triplet, state);
      break;
    }
    case "soil-to-fertilizer": {
      processMapInput(soilToFertilizerMap, word, triplet, state);
      break;
    }
    case "fertilizer-to-water": {
      processMapInput(fertilizerToWaterMap, word, triplet, state);
      break;
    }
    case "water-to-light": {
      processMapInput(waterToLightMap, word, triplet, state);
      break;
    }
    case "light-to-temperature": {
      processMapInput(lightToTemperatureMap, word, triplet, state);
      break;
    }
    case "temperature-to-humidity": {
      processMapInput(temperatureToHumidityMap, word, triplet, state);
      break;
    }
    case "humidity-to-location": {
      processMapInput(humidityToLocationMap, word, triplet, state);
      break;
    }

    default: {
      throw new Exception("Unexpected state");
    }
  }
}

void processMapInput(ref ulong[][] mapping, string word, ref ulong[] triplet, ref string state) {
  if (word != "map:") {
    if (word[0].isDigit) {
      triplet ~= word.to!ulong;
      if (triplet.length == 3) {
        mapping ~= triplet; 
        triplet.length = 0;
      }
    } else {
      writeln(format!"change state to: %s"(word));
      state = word;
    }
  }
}

ulong findMapped (ulong input, ulong[][] mappeds) {
  ulong output = 0;
  bool mappingFound = false;
  foreach(mapped; mappeds) {
    if ( (input >= mapped[1]) &&
         (input <= mapped[1] + mapped[2] -1) ) {
          output = mapped[0] + input - mapped[1];
          mappingFound = true;
          break;
    }
  }
  if (!mappingFound) {
    output = input;
  }
  return output;
}

