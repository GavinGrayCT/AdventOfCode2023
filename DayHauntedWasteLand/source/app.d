import std.stdio;
import core.time;
import std.conv;
import std.format;
import std.file;
import std.algorithm;
import std.ascii;
import std.bigint;

char[] directives;
string[][string] nodes;

void main()
{
  string answerTextPart1 = "Day x, Part 1:";
  string answerTextPart2 = "Day x, Part 2:";
  ulong answerPart1 = 0;
  BigInt answerPart2 = 1;
  auto startTime = MonoTime.currTime;
  auto pathFilename = "data/thedata.txt";
  string data = cast(string)read(pathFilename);

  foreach (word; splitter(data)) {
    extractData(word);
  }

  // Debug
  foreach(key; nodes.keys) {
    writeln(format!"key: %s, left: %s, right: %s"(key, nodes[key][0], nodes[key][1]));
  }

  writeln(format!"directives.length: %s"(directives.length));
  // Get initial nodes name
  string[] nodesName;
  foreach(name; nodes.keys) {
    if (name[2] == 'A') {
      nodesName ~= name;
    }
  }

  writeln(format!"Starting nodes: %s"(nodesName));

  ulong step = 0;
  ulong index = 0;
  ulong[] lastZStep;
  ulong[] intervals;
  lastZStep.length = nodesName.length;
  intervals.length = nodesName.length;
  for (ulong i = 0; ; i++) {
    index = i % directives.length;
    step += 1;
    bool allEndInZ = false;
    // writeln(format!"Step: %s, node names: %s"(step, nodesName));
   for (ulong j = 0; j < nodesName.length; j++) {
      string name = to!string(nodesName[j]);
      //writeln(format!"nodesName[0]: %s, name: %s"(nodesName[0], name));
      string[]aLeftRight = nodes[name];
      // writeln(format!"i: %s, j: %s, name: %s, directive: %s, left: %s, right: %s"(i, j, name, directives[index], aLeftRight[0], aLeftRight[1]));
      if (directives[index] == 'L') {
        nodesName[j] = aLeftRight[0];
      } else if (directives[index] == 'R') {
        nodesName[j] = aLeftRight[1];
      } else {
        throw new Exception(format!"Expected L or R, got: |%s|"(directives[index]));
      }
      if (nodesName[j][2] == 'Z') {
        intervals[j] = step - lastZStep[j];
        lastZStep[j] = step;
        writeln(format!"Got --Z in: %s, at step: %s, interval: %s, j: %s"(nodesName[j], step, intervals[j], j));
        // allEndInZ = false;
        // break;
      }
    }
    if (allEndInZ) {
      break;
    }
    if (step > 100_000) { // 14_321_394_058_031 JG
      //throw new Exception(format!"Probably not going to finish. Staps: %s"(step));
      break;
    }
  }
  writeln(format!"Intervals %s"(intervals));
  ulong gcdIntervals = gcdOfArray(intervals);
  writeln("The GCD of the array is: ", gcdIntervals);
  ulong[] remainders;
  foreach(interval; intervals) {
    remainders ~= interval % gcdIntervals;
  }

  BigInt productIntervals = 1;
  foreach(i, a; intervals) {
    if (i == 0) {
      a = a / gcdIntervals;
    }
    productIntervals *= a;
  }
  answerPart2 = productIntervals;
  writeln(format!"productIntervals: %s, gcd: %s, answerPart2: %s, ulong.max: %s"(productIntervals, gcdIntervals, answerPart2, ulong.max));
  writeln(format!"Remainders: %(%s %)"(remainders));

  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Calc duration ==> %s usecs", duration.total!"usecs");
  writeln(format!"%s %s"(answerTextPart1, answerPart1));
  writeln(format!"%s %s"(answerTextPart2, answerPart2));
}

string state = "Get Directives";
string nodeName = "";
string[] leftRight;
void extractData(string word) {
  writeln(format!"Word is: %s"(word));
  switch (state) {
    case "Get Directives": {
      directives = cast(char[])word;
      state = "Get Node Name";
      break;
    }
    case "Get Node Name": {
      nodeName = word;
      state = "Get =";
      break;
    }
    case "Get =": {
      state = "Get Left";
      break;
    }
    case "Get Left": {
      leftRight ~= word[1..$-1];
      state = "Get Right";
      break;
    }
    case "Get Right": {
      leftRight ~= word[0..$-1];
      state = "Get Node Name";
      nodes[nodeName] = leftRight;
      leftRight = [];
      break;
    }
    default: {
      throw new Exception(format!"Uknown state: |%s|"(state));
    }
  }
}

import std.stdio;
import std.algorithm;
import std.array;

// Function to find the GCD of two numbers
ulong gcd(ulong a, ulong b) {
    while (b != 0) {
        ulong t = b;
        b = a % b;
        a = t;
    }
    return a;
}

// Function to find the GCD of an array of ulongs
ulong gcdOfArray(ulong[] arr) {
    ulong result = arr[0];
    foreach (num; arr[1 .. $]) {
        result = gcd(result, num);
        if (result == 1) {
            return 1; // Early exit if GCD becomes 1
        }
    }
    return result;
}

// void main() {
//     // Example usage
//     ulong[] numbers = [24, 60, 36]; // Replace with your set of ulongs
//     writeln("The GCD of the array is: ", gcdOfArray(numbers));
// }

