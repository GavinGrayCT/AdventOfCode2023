import std.stdio;
import std.ascii;
import core.time;
import std.conv;
import std.format;

struct Item {
  ulong partNo;
  char symbol = 0;
  ulong c1, c2; // start and end of box
}


void main() {
  Item[][] parts;
  Item[][] symbols;

  auto startTime = MonoTime.currTime;
  auto file = File("data/thedata.txt"); // Open for reading
  ulong answerPart1;
  ulong answerPart2;
  auto range = file.byLine();
  foreach (line; range) {
    Item[] partsInRow;
    Item[] symbolsInRow;
    fillItemsData(line, partsInRow, symbolsInRow);
    parts ~= partsInRow;
    symbols ~= symbolsInRow;
  }

  // Debug
  foreach(row, rowParts; parts) {
    foreach(part; rowParts) {
      writefln("row: %s, partNo: %s, c1: %s. c2: %s", row, part.partNo, part.c1, part.c2);
    }
  }
  foreach(row, rowSybols; symbols) {
    foreach(aSymbol; rowSybols) {
      writefln("row: %s, symbol %s, c1: %s. c2: %s", row, aSymbol.symbol, aSymbol.c1, aSymbol.c2);
    }
  }

  calcAnswerPart1(parts, symbols, answerPart1);
  writefln("\nPart 2");
  calcAnswerPart2(parts, symbols, answerPart2);
  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Gear Ratios Duration ==> %s usecs", duration.total!"usecs");
  writefln("Sum of all of the part numbers in the engine schematic: %s", answerPart1);
  writefln("Sum of all of the gears numbers in the engine schematic: %s", answerPart2);
}

void fillItemsData(char[] line, ref Item[] partsInRow, ref Item[] symbolsInRow) {
  writefln("fillItemsData - line: %s", line);
  string numStr = "";
  string state = "start";
  Item* item = new Item;
  foreach(col, chr; line) {
    writefln("col: %s, chr: %s, state: %s", col, chr, state);
    switch (state) {
      case "start": {
        writefln("in start");
        if (chr.isDigit) {
          writefln("in if");
          numStr ~= chr;
          writefln("numStr: %s", numStr);
          item.c1 = col;
          state = "in_number";
          writefln("item.c1: %s, state: %s", item.c1, state);
        } else if (chr != '.') { // symbol
          item.c1 = (col == 0? 0 : col -1);
          item.c2 = (col == line.length -1? col : col +1);
          item.symbol = chr;
          symbolsInRow ~= *item;
          item = new Item;
        }
        break;
      }
      case "in_number": {
        writefln("in in_number");
        if (chr.isDigit) {
          numStr ~= chr;
        } else {
          item.partNo = numStr.to!ulong;
          item.c2 = col-1;
          partsInRow ~= *item;
          item = new Item;
          if (chr != '.') { // symbol
            item.c1 = (col == 0? 0 : col -1);
            item.c2 = (col == line.length -1? col : col +1);
            item.symbol = chr;
            symbolsInRow ~= *item;
            item = new Item;
          }
          state = "start";
          numStr = "";
        }
        break;
      }
    
      default:
        break;
    } 
  }
  if (state == "in_number") {
    item.partNo = numStr.to!ulong;
    item.c2 = item.c1 + numStr.length -1;
    partsInRow ~= *item;
  }
}

void calcAnswerPart1(const Item[][] parts, const Item[][] symbols, ref ulong answer) {
  bool added = false;
  foreach(row, partsRow; parts) {
    foreach(part; partsRow) {
      if (row >= 1) {
        added = calcForPart(part, symbols[row -1], answer);
      }
      if (!added) {
        calcForPart(part, symbols[row], answer);
        if (!added) {
          if (row < parts.length -1) {
            calcForPart(part, symbols[row +1], answer);
          }
        }
      }
    }
  }
}

bool calcForPart(const Item part, const Item[] symbols, ref ulong answer) {
  bool added = false;
  foreach(symbol; symbols) {
    if ( (part.c1 <= symbol.c2) && (part.c2 >= symbol.c1) ) {
      answer += part.partNo;
      added = true;
    }
  }
  return added;
}

void calcAnswerPart2(const Item[][] parts, const Item[][] symbols, ref ulong answer) {
  foreach(row, symbolRow; symbols) {
    foreach(symbol; symbolRow) {
      if (symbol.symbol == '*') {
        writeln(format!"row: %s, symbol: %s, c1: %s, c2: %s"(row, symbol.symbol, symbol.c1, symbol.c2));
        Item[] symbolGears;
        if (row >= 1) {
          calcGearsForSymbol(parts[row-1], symbol, symbolGears);
        }
        calcGearsForSymbol(parts[row], symbol, symbolGears);
        if (row < parts.length -1) {
          calcGearsForSymbol(parts[row+1], symbol, symbolGears);
        }
        if (symbolGears.length == 2) {
          writefln("First is: %s, Second is:%s", symbolGears[0].partNo, symbolGears[1].partNo);
          answer += symbolGears[0].partNo * symbolGears[1].partNo;
        }
      }
    }
  }
}

void calcGearsForSymbol(const Item[] partsRow, Item symbol, ref Item[] symbolGears) {
  foreach (part; partsRow) {
    writeln(format!"part: %s, c1: %s, c2: %s"(part.partNo, part.c1, part.c2));
    if ( (part.c1 <= symbol.c2) && (part.c2 >= symbol.c1) ) {
      symbolGears ~= part;
    }
  }
}