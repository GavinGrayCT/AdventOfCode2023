import std.stdio;
import std.string;
import std.array;
import core.time;
import std.conv;
import std.format;
import std.uni;
import std.algorithm;

struct Card {
  ulong cardNo;
  ulong[] winningNumbers;
  ulong[] scratchedNumbers;
}

void main() {
  Card[] cards;
  auto startTime = MonoTime.currTime;
  auto file = File("data/thedata.txt"); // Open for reading
  ulong answerPart1 = 0;
  auto range = file.byLine();
  foreach (line; range) {
    cards ~= fillCard(line);
  }

  // Debug
  foreach(card; cards) {
    writeln(format!"Card: %s, winning numbers:%s, scratched numbers:%s"(card.cardNo, card.winningNumbers, card.scratchedNumbers));
  }

  foreach(card; cards) {
    answerPart1 += calcWinningsCard(card);
  }

  // calcAnswerPart1(parts, symbols, answerPart1);
  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Gear Ratios Duration ==> %s usecs", duration.total!"usecs");
  writefln("Sum of all of the winnings: %s", answerPart1);
}

Card fillCard(const char[] line) {
  string[] cardParts = (cast(string)line).split(":");
  Card card;
  // writeln(format!"After chomp: %s"(cardParts[0].chompPrefix("Card ")));
  card.cardNo = (cardParts[0].chompPrefix("Card ").strip).to!ulong;
  string[] allNumbers = cardParts[1].split("|");
  card.winningNumbers = allNumbers[0].split().map!(to!ulong).array;
  card.scratchedNumbers = allNumbers[1].split().map!(to!ulong).array;
  return card;
}

ulong calcWinningsCard(const Card card) {
  ulong winnings = 0;
  foreach(winNr; card.winningNumbers) {
    foreach (ulong scratchedNumber; card.scratchedNumbers) {
      if (scratchedNumber == winNr) {
        winnings = winnings == 0? 1: winnings *2;
        // writeln(format!"Card: %s, Matched: %s, Winnings: %s"(card.cardNo, scratchedNumber, winnings));
      }
    }
  }
  return winnings;
}
