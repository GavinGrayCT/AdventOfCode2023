import std.stdio;
import core.time;
import std.conv;
import std.format;
import std.file;
import std.algorithm;
import std.ascii;

char[] directives;
string[][string] nodes;

void main()
{
  string answerTextPart1 = "Day x, Part 1:";
  string answerTextPart2 = "Day x, Part 2:";
  ulong answerPart1 = 0;
  ulong answerPart2 = 0;
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
    nodeName = "AAA";
    ulong steps = 0;
    ulong index = 0;
    for (int i = 0; ; i++) {
      index = i % directives.length;
      steps += 1;
      string[]aLeftRight = nodes[nodeName];
      writeln(format!"i: %s, nodeName: %s, directive: %s, left: %s, right: %s"(i, nodeName, directives[index], aLeftRight[0], aLeftRight[1]));
      if (directives[index] == 'L') {
        nodeName = aLeftRight[0];
      } else if (directives[index] == 'R') {
        nodeName = aLeftRight[1];
      } else {
        throw new Exception(format!"Expected L or R, got: |%s|"(directives[index]));
      }
      if (nodeName == "ZZZ") {
        break;
      }
      if (steps > 1000000) {
        throw new Exception(format!"Probably not going to finish");
      }
    }
    answerPart1 = steps;

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

