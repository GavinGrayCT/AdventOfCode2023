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
  ulong winners;
  ulong copies = 1;
}

void main() {
  Card[] cards;
  auto startTime = MonoTime.currTime;
  auto file = File("data/thedata.txt"); // Open for reading
  ulong answerPart1 = 0;
  ulong answerPart2 = 0;
  auto range = file.byLine();
  foreach (line; range) {
    cards ~= fillCard(line);
  }

  foreach(ref card; cards) {
    card.winners = calcWinnersCard(card);
    answerPart1 += 2 ^^ (card.winners - 1);
  }

  answerPart2 = calcTotalCards(cards);

  // Debug
  foreach(card; cards) {
    writeln(format!"Card: %s, winning numbers:%s, scratched numbers:%s, winners: %s, copies: %s"
                   (card.cardNo, card.winningNumbers, card.scratchedNumbers, card.winners, card.copies));
  }

  // calcAnswerPart1(parts, symbols, answerPart1);
  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Gear Ratios Duration ==> %s usecs", duration.total!"usecs");
  writefln("Sum of all of the winnings: %s", answerPart1);
  writeln(format!"Total scratchcards: %s"(answerPart2));
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

ulong calcWinnersCard(const Card card) {
  ulong winners = 0;
  foreach(winNr; card.winningNumbers) {
    foreach (ulong scratchedNumber; card.scratchedNumbers) {
      if (scratchedNumber == winNr) {
        winners += 1;
        // writeln(format!"Card: %s, Matched: %s, Winnings: %s"(card.cardNo, scratchedNumber, winnings));
      }
    }
  }
  return winners;
}

  ulong calcTotalCards(Card[] cards) {
    ulong totalCards = 0;
    foreach(card; cards) {
      totalCards += card.copies;
      for (int i = 0; i < card.winners; i++) {
        cards[card.cardNo +i].copies += card.copies;
      }
    }
    return totalCards;
  }


