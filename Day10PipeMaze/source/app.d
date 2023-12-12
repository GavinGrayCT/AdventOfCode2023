import std.stdio;
import core.time;
import std.conv;
import std.format;
import std.file;
import std.algorithm;
import std.ascii;
import std.string;

struct Tile {
  char c;
  long row = -1;
  long col;
  char[] dirs;
  long previousRow;
  long previousCol;
  long steps = 0;
}

struct Step {
  Tile tileA;
  Tile tile1;
}

Tile[][] grid;

Tile start;

void main()
{
  string answerTextPart1 = "Day x, Part 1:";
  string answerTextPart2 = "Day x, Part 2:";
  ulong answerPart1 = 0;
  ulong answerPart2 = 0;
  auto startTime = MonoTime.currTime;
  auto pathFilename = "data/thedata.txt";
  string data = cast(string)read(pathFilename);

  long row;
  foreach (line; lineSplitter(data)) {
    extractData(row++, line);
  }

  if (start.row == -1) {
    throw new Exception(format!"No start tile found");
  }

  
  Tile[] tilesAfterStart;
  for (long r = start.row -1; r <= start.row +1; r++) {
    for (long c = start.col -1; c <= start.col +1; c++) {
      if ( (r == start.row) || (c == start.col)) {
        if (isNextTile(start, r, c)) {
          Tile aTile = grid[r][c];
          aTile.previousRow = start.row;
          aTile.previousCol = start.col;
          tilesAfterStart ~= aTile;
        }
      }
    }
  }

  writeln(format!"Tiles after start tilesAfterStart: %s"(tilesAfterStart));


  long steps =1;
  bool done = false;
  Tile nextA = tilesAfterStart[0];
  Tile nextB = tilesAfterStart[1];
  while (!done) {
    nextA = nextTile(nextA);
    nextB = nextTile(nextB);
    steps +=1;
    writeln(format!"================= nextA: %s, nextB: %s, steps: %s"(nextA, nextB, steps));
    if ( (nextA.row == nextB.row) && (nextA.col == nextB.col) ) {
      done = true;
    }
  }

  // Debug
  // writeln(format!"grid: %s"(grid));

  auto endTime = MonoTime.currTime;
  auto duration = endTime - startTime;
  writefln("Calc duration ==> %s usecs", duration.total!"usecs");
  writeln(format!"%s %s"(answerTextPart1, answerPart1));
  writeln(format!"%s %s"(answerTextPart2, answerPart2));
}

void extractData(long row, string line) {
  writeln(format!"Line is: %s"(line));
  Tile[] rowOfTiles;
  Tile tile;
  foreach(col, c; line) {
    tile.c = c;
    tile.row = row;
    tile.col = col;
    setDirections(c, tile);
    rowOfTiles ~= tile;
  }
  grid ~= rowOfTiles;
}

void setDirections(char c, ref Tile tile) {
  if (c == '|') {
    tile.dirs = ['N', 'S'];
  } else if (c == '-') {
    tile.dirs = ['E','W'];
  } else if (c == 'L') {
    tile.dirs = ['N', 'E'];
  } else if (c == 'J') {
    tile.dirs = ['N', 'W'];
  } else if (c == '7') {
    tile.dirs = ['S', 'W'];
  } else if (c == 'F') {
    tile.dirs = ['S', 'E'];
  } else if (c == 'S') {
    tile.dirs = ['0', '0'];
    start = tile;
  } else if (c == '.') {
    tile.dirs = ['0', '0'];
  } else {
    throw new Exception(format!"Uknown pipe connector: %s at row: %s, col: %s"(c, tile.row, tile.col));
  }
}


bool isNextTile(Tile tile, long row, long col) {
  writeln(format!"isNextTile. tile: %s, candidate row: %s, col: %s"(tile, row, col));
  if ( (row >= 0) && (row < grid.length) ){
    if ( (col >= 0) && (col < grid[0].length) ) {
      if (col == tile.col) {
        if (row == tile.row -1) {
          writeln(format!"1 candidate tile: %s"(grid[row][col]));
          if ( (grid[row][col].dirs[0] == 'S') || (grid[row][col].dirs[1] == 'S') ) {
            writeln("1 true");
            return true;
          }
        }
        if (row == tile.row +1) {
          writeln(format!"2 candidate tile: %s"(grid[row][col]));
          if ( (grid[row][col].dirs[0] == 'N') || (grid[row][col].dirs[1] == 'N') ) {
            writeln("2 true");
            return true;
          }
        }
      }
      if (row == tile.row) {
        if (col == tile.col -1) {
          writeln(format!"3 candidate tile: %s"(grid[row][col]));
          if ( (grid[row][col].dirs[0] == 'E') || (grid[row][col].dirs[1] == 'E') ) {
            writeln("3 true");
            return true;
          }
        }
        if (col == tile.col +1) {
          writeln(format!"4 candidate tile: %s"(grid[row][col]));
          if ( (grid[row][col].dirs[0] == 'W') || (grid[row][col].dirs[1] == 'W') ) {
            writeln("4 true");
            return true;
          }
        }
      }
    }
  }
  writeln(format!"Not next tile");
  return false;
}

Tile nextTile(Tile currentTile) {
  writeln(format!"nextTile from currentTile: %s"(currentTile));
  Tile theNextTile;
  if ( (currentTile.dirs[0] == 'W') || (currentTile.dirs[1] == 'W') ) {
    writeln(format!"W");
    if (isNextTile(currentTile, currentTile.row, currentTile.col -1)) {
      if ( (currentTile.previousRow != currentTile.row) || ( (currentTile.previousCol) != currentTile.col -1) ) {
        theNextTile = grid[currentTile.row][currentTile.col -1];
        theNextTile.previousRow = currentTile.row;
        theNextTile.previousCol = currentTile.col;
        writeln(format!"In W. theNextTile: %s"(theNextTile));
        return theNextTile;
      }
    }
  }
  if ( (currentTile.dirs[0] == 'S') || (currentTile.dirs[1] == 'S') ) {
    writeln(format!"S");
    if (isNextTile(currentTile, currentTile.row +1, currentTile.col)) {
      if ( (currentTile.previousRow != currentTile.row +1) || ( currentTile.previousCol != currentTile.col) ) {
        theNextTile = grid[currentTile.row +1][currentTile.col];
        theNextTile.previousRow = currentTile.row;
        theNextTile.previousCol = currentTile.col;
        writeln(format!"In S. theNextTile: %s"(theNextTile));
        return theNextTile;
      }
    }
  }
  if ( (currentTile.dirs[0] == 'E') || (currentTile.dirs[1] == 'E') ) {
    writeln(format!"E");
    if (isNextTile(currentTile, currentTile.row, currentTile.col +1)) {
      if ( (currentTile.previousRow != currentTile.row) || ( currentTile.previousCol != currentTile.col +1) ) {
        theNextTile = grid[currentTile.row][currentTile.col +1];
        theNextTile.previousRow = currentTile.row;
        theNextTile.previousCol = currentTile.col;
        writeln(format!"In E. theNextTile: %s"(theNextTile));
        return theNextTile;
      }
    }
  }
  if ( (currentTile.dirs[0] == 'N') || (currentTile.dirs[1] == 'N') ) {
    writeln(format!"N");
    if (isNextTile(currentTile, currentTile.row -1, currentTile.col)) {
      if ( (currentTile.previousRow != currentTile.row -1) || ( currentTile.previousCol != currentTile.col) ) {
        theNextTile = grid[currentTile.row -1][currentTile.col];
        theNextTile.previousRow = currentTile.row;
        theNextTile.previousCol = currentTile.col;
        writeln(format!"In N. theNextTile: %s"(theNextTile));
        return theNextTile;
      }
    }
  }
  assert(0);
}

//   Tile nextTile;
//   if (tile.row > 0) {
//     if (notTile.row != row -1) {
//       if ( (grid[row][col].dir1 == 'S') || (grid[row][col].dir2 == 'S') ) {
//         nextTile.row = tile.row -1;
//         nextTile.col = tile.col;
//         setDirections(grid[row -1, col].c, nextTile);
//       }
//     }
//   }
//   if (tile.col > 0) {
//     if (notTile.col != col) {

//   }


//   for (long row = max(tile.row -1, 0); row < min(tile.row+1, grid.length); row++) {
//     for (long col = max(tile.col -1, 0); col < min(tile.col+1, grid[0].length); col++) {
//       if ( (row == tile.row -1) && ( (grid[row][col].dir1 == 'S') || (grid[row][col].dir2 == 'S')) ) {
//         if ( (notTile.row != row -1) || (notTile.col != col) ) {
//           nextTile.row = row;
//           nextTile.col = col;
//         }
//       }
//       if ( (row == tile.row +1) && ( (grid[row][col].dir1 == 'S') || (grid[row][col].dir2 == 'S')) ) {
//         if ( (notTile.row != row +1) || (notTile.col != col) ) {
//           nextTile.row = row;
//           nextTile.col = col;
//         }
//       }
//     }
//   }
//   Step nextStep;
//   return nextStep;
// }

