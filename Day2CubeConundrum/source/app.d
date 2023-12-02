import std.stdio;
import std.array;
import std.regex;
import std.typecons;
import std.uni;
import std.conv;
import core.time;
import std.algorithm;

struct Handfull {
  ulong red;
  ulong green;
  ulong blue;
}

struct Game {
  ulong maxRed;
  ulong maxGreen;
  ulong maxBlue;
}

enum States {
  gettingNumber,
  gettingColor
}


void main()
{
  Handfull bag = Handfull(12, 13, 14);
  auto file = File("data/thedata.txt"); // Open for reading

  auto startTime = MonoTime.currTime;
  ulong sumPosibleGameIds = 0;
  auto range = file.byLine();
  foreach (line; range) {
    sumPosibleGameIds += processGame(cast(string)line, bag);
  }

  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Hello Duration ==> %s usecs", duration.total!"usecs");
  writefln("The sum of IDs of possible games is %s", sumPosibleGameIds);
}

ulong processGame(string gameLine, Handfull bag) {
  // writefln("gameLine: %s", gameLine);
  ulong result;
  string[] game = gameLine.split(":");
  string[] gameDetails = game[0].split!isWhite;
  ulong gameId = gameDetails[1].to!ulong;
  string[] gameStrs = game[1].split(";");
  Game aGame;
  foreach(gameStr; gameStrs) {
    // writefln("gameStr: %s", gameStr);
    string[] handfullStrs = gameStr.split(",");
    Handfull handfull;
    foreach(handfullStr; handfullStrs) {
      // writefln("handfullStr: |%s|", handfullStr);
      string[] colorGrab = handfullStr.split!isWhite;
      // writefln("colorGrab[1]: %s, colorGrab[1]: %s", colorGrab[1], colorGrab[2]);
      switch (colorGrab[2]) {
        case "red":
          handfull.red = to!ulong(colorGrab[1]);
          break;
        case "green":
          handfull.green = to!ulong(colorGrab[1]);
          break;
        case "blue":
          handfull.blue = to!ulong(colorGrab[1]);
          break;
        
        default: break;
      }
    }
    aGame.maxRed = max(aGame.maxRed, handfull.red);
    // writefln("handfull.red: %s", handfull.red);
    aGame.maxGreen = max(aGame.maxGreen, handfull.green);
    aGame.maxBlue = max(aGame.maxBlue, handfull.blue);
  }
  // writefln("bag.red: %s, aGame.maxRed: %s", bag.red, aGame.maxRed);
  // writefln("bag.green: %s, aGame.maxGreen: %s", bag.green, aGame.maxGreen);
  // writefln("bag.blue: %s, aGame.maxblue: %s", bag.blue, aGame.maxBlue);
  if ( (bag.red >= aGame.maxRed) &&
       (bag.green >= aGame.maxGreen) &&
       (bag.blue >= aGame.maxBlue) ) {
        result = gameId;
  } else {
    result = 0;
  }
  // writefln("result: %s", result);
  return result;
}
