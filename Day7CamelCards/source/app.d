import std.stdio;
import core.time;
import std.conv;
import std.format;
import std.file;
import std.algorithm;
import std.ascii;

struct Hand {
  char[] cards;
  ulong bid;
  ulong type;
  ulong rank;
  ulong[] cardsNr;
  ulong winnings;
}

Hand[] hands;

void main()
{
  string answerTextPart1 = "Day 7, Part 1 - Total Winnings:";
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
  writeln("After extractData. Hands");
  foreach(i, hand; hands) {
    writeln(format!"%s cards: %s, bid: %s, type: %s, rank: %s"(i, hand.cards, hand.bid, hand.type, hand.rank));
  }


  // Generate cardsNr
  foreach (ref hand; hands) {
    ulong[] cardsNr;
    foreach(card; hand.cards) {
      writeln(format!"Card: %s"(card));
      if ( (card >= '2') && (card <= '9') ) {
        cardsNr ~= to!ulong(to!string(card));
      } else if (card == 'T') {
        cardsNr ~= 10;
      } else if (card == 'J') {
        cardsNr ~= 1;
      } else if (card == 'Q') {
        cardsNr ~= 11;
      } else if (card == 'K') {
        cardsNr ~= 12;
      } else if (card == 'A') {
        cardsNr ~= 13;
      } else {
        throw new Exception(format!"Non-existant card: |%s|"(card));
      }
    }
    hand.cardsNr = cardsNr;
    writeln(format!"cards: %s, bid: %s, type: %s, rank: %s, cardsNr: %s"(hand.cards, hand.bid, hand.type, hand.rank, hand.cardsNr));
  }

  sort!((a,b) => compare(a,b) < 0)(hands);
  foreach(i, ref hand; hands) {
    hand.rank = i +1;
    answerPart1 += hand.rank * hand.bid;
  }

  // Debug
  writeln("Hands");
  foreach(i, hand; hands) {
    writeln(format!"%s cards: %s, bid: %s, type: %s, rank: %s"(i, hand.cards, hand.bid, hand.type, hand.rank));
  }


  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Calc duration ==> %s usecs", duration.total!"usecs");
  writeln(format!"%s %s"(answerTextPart1, answerPart1));
  writeln(format!"%s %s"(answerTextPart2, answerPart2));
}

string state = "Cards";
char[] cards;
void extractData(string word) {
  writeln(format!"Word is: %s"(word));
  switch (state) {
    case "Cards": {
      cards = cast(char[])word;
      state = "Bid";
      break;
    }
    case "Bid": {
      state = "Cards";
      Hand hand = Hand(cards, to!ulong(word), getHandType(cards));
      writeln(format!"in extractData. Hand is: %s"(hand));
      hands ~= hand;
      break;
    }
    default: {
        throw new Exception(format!"Non-existant state: |%s|"(state));
    }
  }
}

ulong getHandType(char[] cards) {
  ulong[char] cardToCountMap;
  ulong type = 0;
  ulong jokerCount = 0;
  foreach(card; cards) {
    if (card == 'J') {
      jokerCount += 1;
    } else {
      if (card in cardToCountMap) {
        cardToCountMap[card] += 1;
      } else {
        cardToCountMap[card] = 1;
      }
    }
  }
  foreach(key; cardToCountMap.keys) {
    if (cardToCountMap[key] == 2) {
      type += 1;
    } else if (cardToCountMap[key] == 3) {
      type += 3;
    } else if (cardToCountMap[key] == 4) {
      type = 5;
    } else if (cardToCountMap[key] == 5) {
      type = 6;
    }
  }
  // Add in jokers to type
  // type 0 => + jokerCount; type 1 => 2 + jokerCount; type 2 => 2+jokerCount;
  // type 3 => 3 + jokerCount;
  // type 4 cannot have jokers; type 5 => 5 + jokerCount;
  if (type == 0) {
    if (jokerCount == 1) {
      type = 1;
    } else if (jokerCount == 2) {
      type = 3;
    } else if (jokerCount == 3) {
      type = 5;
    } else if (jokerCount == 4) {
      type = 6;
    } else if (jokerCount == 5) {
      type = 6;
    } else if (jokerCount > 5) {
        throw new Exception(format!"Too many jokers: %s"(jokerCount));
    }
  } else if (type == 1) {
    if (jokerCount == 1) {
      type = 3;
    } else if (jokerCount == 2) {
      type = 5;
    } else if (jokerCount == 3) {
      type = 6;
    } else if (jokerCount > 3) {
        throw new Exception(format!"Too many jokers: %s"(jokerCount));
    }
  } else if (type == 2) {
    if (jokerCount == 1) {
      type = 4;
    } else if (jokerCount > 1) {
        throw new Exception(format!"Too many jokers: %s"(jokerCount));
    }
  } else if (type == 3) {
    if (jokerCount == 1) {
      type = 5;
    } else if (jokerCount == 2) {
      type = 6;
    } else if (jokerCount > 2) {
        throw new Exception(format!"Too many jokers: %s"(jokerCount));
    }
  } else if (type == 4) {
    if (jokerCount > 0) {
        throw new Exception(format!"Too many jokers: %s"(jokerCount));
    }
  } else if (type == 5) {
    if (jokerCount == 1) {
      type = 6;
    } else if (jokerCount > 1) {
      throw new Exception(format!"Too many jokers: %s"(jokerCount));
    }
  } else if (type == 6) {
    if (jokerCount > 0) {
        throw new Exception(format!"Too many jokers: %s"(jokerCount));
    }
  }
  return type;
}

int compare(Hand a, Hand b) {
  writeln(format!"Comparing a: %s, b: %s"(a, b));
  if (a.type < b.type) {return -1;}
  if (a.type == b.type) {
    writeln(format!"a: %s, b: %s"(a, b));
    for (int i = 0; i < a.cardsNr.length; i++) {
      writeln(format!"i: %s, a: %s, b: %s"(i, a.cardsNr[i], b.cardsNr[i]));
      if (a.cardsNr[i] == b.cardsNr[i]) {
      } else {
        writeln(format!"Returning: %s"(b.cardsNr[i] - a.cardsNr[i]));
        return to!int(a.cardsNr[i]) - to!int(b.cardsNr[i]);
      }
    }
  }
  return 1;
}