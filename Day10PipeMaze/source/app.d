import std.stdio;
import core.time;
import std.conv;
import std.format;
import std.file;
import std.algorithm;
import std.ascii;
import std.string;

struct Tile {
  char c;   // should not be changed
  char dc;  // for printing
  long row = -1;
  long col;
  char[] dirs;
  long previousRow;
  long previousCol;
  long steps = 0;
  bool partOfLoop = false;
  char insideDir = '?';
  char moved = '?';
  bool isInside = false;
  bool isStart = false;
}

struct Step {
  Tile tileA;
  Tile tile1;
}

Tile[][] grid;

Tile* start;
long[2] startpoint;

long turns = 0;

long tilesInside = 0;

void main()
{
  string answerTextPart1 = "Day x, Part 1:";
  string answerTextPart2 = "Day x, Part 2:";
  ulong answerPart1 = 0;
  long answerPart2 = 0;
  auto startTime = MonoTime.currTime;
  auto pathFilename = "data/thedata.txt";
  string data = cast(string)read(pathFilename);

  long row;
  foreach (line; lineSplitter(data)) {
    extractData(row++, line);
  }
  start = &grid[startpoint[0]][startpoint[1]];
  start.isStart = true;


  if (start.row >= 0) {
    writeln(format!"Start: row: %s, col: %s, dirs: %s"(start.row, start.col, start.dirs));
  } else {
    throw new Exception(format!"No start tile found");
  }

  
  Tile[] tilesAfterStart;
  start.dirs.length = 0;
  for (long r = start.row -1; r <= start.row +1; r++) {
    for (long c = start.col -1; c <= start.col +1; c++) {
      if ( (r == start.row) || (c == start.col)) {
        if (isNextTile(*start, r, c)) {
          Tile aTile = grid[r][c];
          aTile.previousRow = start.row;
          aTile.previousCol = start.col;
          tilesAfterStart ~= aTile;
        }
      }
    }
  }

  correctCForStart;
  writeln(format!"Start: %s followed by tilesAfterStart: %s"(*start, tilesAfterStart));

  long steps =1;
  bool done = false;
  Tile nextA = tilesAfterStart[0];
  Tile nextB = tilesAfterStart[1];
  while (!done) {
    nextA = nextTile(nextA);
    nextB = nextTile(nextB);
    steps +=1;
    // writeln(format!"================= nextA: %s, nextB: %s, steps: %s"(nextA, nextB, steps));
    if ( (nextA.row == nextB.row) && (nextA.col == nextB.col) ) {
      done = true;
    }
  }

  // Part 2 - Rewalk in one direction until back to start.
  //          Count E->S, S->W, W->N, N->E as 1,
  //          E->N, N->W, W->S, S-> as -1. Add to get direction
  writeln(format!"============================= Starting Part 2 from start: %s"(start));
  steps = 0;
  turns = 0;
  done = false;
  nextA = *start;
  while (!done) {
    nextA = nextTile(nextA);
    grid[nextA.row][nextA.col] = nextA;
    steps +=1;
    // writeln(format!"================= nextA: %s, steps: %s"(nextA, steps));
    if ( (nextA.row == start.row) && (nextA.col == start.col) ) {
      start.previousRow = nextA.previousRow;
      start.previousCol = nextA.previousCol;
      done = true;
    }
  }

  writeln(format!"================= steps: %s, turns: %s"(steps, turns));

  // Mark all loop as * except S, non-loop as .
  foreach(rowTiles; grid) {
    foreach (colTile; rowTiles) {
      if (grid[colTile.row][colTile.col].partOfLoop) {
        grid[colTile.row][colTile.col].dc = '*';
      } else {
        grid[colTile.row][colTile.col].dc = '.';
      }
    }
  }

  foreach(rowTiles; grid) {
    foreach (colTile; rowTiles) {
      write(format!"%s"(colTile.dc));
    }
    writeln;
  }

  foreach(rowTiles; grid) {
    foreach (colTile; rowTiles) {
      write(format!"%s"(colTile.dc));
    }
    writeln;
  }

// // Clear non-loop tiles touching outside.
//   long[] crossings;
//   long tilesInside = 0;
//   foreach(rowTiles; grid) {
//     foreach (colTile; rowTiles) {
//       crossings ~= 0;
//       if (grid[colTile.row][colTile.col].partOfLoop) { 
//         crossings[colTile.col] += 1;
//       }
//       if ( (crossings[colTile.col] > 0) && !grid[colTile.row][colTile.col].partOfLoop) {
//         // for (long k = colTile.row +1; k < rowTiles.length; k++) {
//         //   if (grid[k][colTile.col].partOfLoop) {crossings[colTile.col] +=1;}
//         // }
//         if (crossings[colTile.col] % 2 == 1) {
//           tilesInside +=1;
//           grid[colTile.row][colTile.col].c = '0';
//         }
//       }
//     }
//   }
  // writeln(format!"\n===================================================================================================\n");
  // foreach(rowTiles; grid) {
  //   foreach (colTile; rowTiles) {
  //     ma;
  //   }
  //   writeln;
  // }

  writeln(format!"============================= Starting Part 2 from start: %s"(start));
  steps = 0;
  turns = 0;
  done = false;
  nextA = *start;
  while (!done) {
    noLoopInsideClockwise(nextA);
    nextA = nextTile(nextA);
    grid[nextA.row][nextA.col] = nextA;
    steps +=1;
    // writeln(format!"================= nextA: %s, steps: %s"(nextA, steps));
    if ( (nextA.row == start.row) && (nextA.col == start.col) ) {
      start.previousRow = nextA.previousRow;
      start.previousCol = nextA.previousCol;
      done = true;
    }
  }


  foreach(rowTiles; grid) {
    foreach (colTile; rowTiles) {
      write(format!"%s"(colTile.c));
    }
    writeln;
  }

  foreach(rowTiles; grid) {
    foreach (colTile; rowTiles) {
      write(format!"%s"(colTile.dc));
    }
    writeln;
  }

  // Fill in touching 0's
  foreach(ref rowTiles; grid) {
    foreach (ref colTile; rowTiles) {
      if (colTile.dc == '0') {
        if (grid[colTile.row][colTile.col +1].dc == '.') {
          grid[colTile.row][colTile.col +1].dc = '0';
          grid[colTile.row][colTile.col +1].isInside = 0;
        }
      }
    }
    writeln;
  }

  // Count 0's
  tilesInside = 0;
  foreach(ref rowTiles; grid) {
    foreach (ref colTile; rowTiles) {
      if (colTile.dc == '0') {
        tilesInside += 1;
      }
    }
    writeln;
  }
  answerPart2 = tilesInside;

  foreach(rowTiles; grid) {
    foreach (colTile; rowTiles) {
      write(format!"%s"(colTile.dc));
    }
    writeln;
  }


  writeln(format!"About to see ? in writeln ==============================================");
  foreach(rowTiles; grid) {
    foreach (colTile; rowTiles) {
      char dc;
      if ( (colTile.dc == '0') || (colTile.dc == '.') ) {
        dc = colTile.dc;
      } else {
        dc = colTile.c;
      }
      write(format!"%s"(dc));
    }
    writeln;
  }

  // writeln(format!"Number of tiles inside: %s"(tilesInside));



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
    tile.dc = c;
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
    startpoint[0] = tile.row;
    startpoint[1] = tile.col;
  } else if (c == '.') {
    tile.dirs = ['0', '0'];
  } else {
    throw new Exception(format!"Uknown pipe connector: %s at row: %s, col: %s"(c, tile.row, tile.col));
  }
}

void correctCForStart() {
  if ( (start.dirs == "EW") || (start.dirs == "WE") ) {
    start.c = '-';
  } else if ( (start.dirs == "NS") || (start.dirs == "SN") ) {
    start.c = '|';
  } else if ( (start.dirs == "NE") || (start.dirs == "EN") ) {
    start.c = 'L';
  } else if ( (start.dirs == "NW") || (start.dirs == "WN") ) {
    start.c = 'J';
  } else if ( (start.dirs == "SW") || (start.dirs == "WS") ) {
    start.c = '7';
  } else if ( (start.dirs == "SE") || (start.dirs == "ES") ) {
    start.c = 'F';
  } else {
    throw new Exception(format!"Start dirs unknown: %s"(start.dirs));
  }
}

bool isNextTile(ref Tile tile, long row, long col) {
  // writeln(format!"isNextTile. tile: %s, candidate row: %s, col: %s"(tile, row, col));
  if ( (row >= 0) && (row < grid.length) ){
    if ( (col >= 0) && (col < grid[0].length) ) {
      if (col == tile.col) {
        if (row == tile.row -1) {
          // writeln(format!"1 candidate tile: %s"(grid[row][col]));
          if ( (grid[row][col].dirs[0] == 'S') || (grid[row][col].dirs[1] == 'S') ) {
            if (tile.c == 'S') {
              tile.dirs ~= 'N';
              tile.moved = 'S';
            }
            // writeln("1 true");
            return true;
          }
        }
        if (row == tile.row +1) {
          // writeln(format!"2 candidate tile: %s"(grid[row][col]));
          if ( (grid[row][col].dirs[0] == 'N') || (grid[row][col].dirs[1] == 'N') ) {
            if (tile.c == 'S') {
              tile.dirs ~= 'S';
              tile.moved = 'N';
            }
            // writeln("2 true");
            return true;
          }
        }
      }
      if (row == tile.row) {
        if (col == tile.col -1) {
          // writeln(format!"3 candidate tile: %s"(grid[row][col]));
          if ( (grid[row][col].dirs[0] == 'E') || (grid[row][col].dirs[1] == 'E') ) {
            if (tile.c == 'S') {
              tile.dirs ~= 'W';
              tile.moved = 'E';
            }
            // writeln("3 true");
            return true;
          }
        }
        if (col == tile.col +1) {
          // writeln(format!"4 candidate tile: %s"(grid[row][col]));
          if ( (grid[row][col].dirs[0] == 'W') || (grid[row][col].dirs[1] == 'W') ) {
            if (tile.c == 'S') {
              tile.dirs ~= 'E';
              tile.moved = 'W';
            }
            // writeln("4 true");
            return true;
          }
        }
      }
    }
  }
  // writeln(format!"Not next tile");
  return false;
}

Tile nextTile(ref Tile currentTile) {
  // writeln(format!"nextTile from currentTile: %s"(currentTile));
  Tile theNextTile;
  if ( (currentTile.dirs[0] == 'W') || (currentTile.dirs[1] == 'W') ) {
    // writeln(format!"W");
    if (isNextTile(currentTile, currentTile.row, currentTile.col -1)) {
      if ( (currentTile.previousRow != currentTile.row) || ( (currentTile.previousCol) != currentTile.col -1) ) {
        theNextTile = grid[currentTile.row][currentTile.col -1];
        theNextTile.previousRow = currentTile.row;
        theNextTile.previousCol = currentTile.col;
        // writeln(format!"In W. theNextTile: %s"(theNextTile));
        theNextTile.partOfLoop = true;
        theNextTile.moved = 'W';
        countTurns(currentTile, theNextTile);
        return theNextTile;
      }
    }
  }
  if ( (currentTile.dirs[0] == 'S') || (currentTile.dirs[1] == 'S') ) {
    // writeln(format!"S");
    if (isNextTile(currentTile, currentTile.row +1, currentTile.col)) {
      if ( (currentTile.previousRow != currentTile.row +1) || ( currentTile.previousCol != currentTile.col) ) {
        theNextTile = grid[currentTile.row +1][currentTile.col];
        theNextTile.previousRow = currentTile.row;
        theNextTile.previousCol = currentTile.col;
        // writeln(format!"In S. theNextTile: %s"(theNextTile));
        theNextTile.partOfLoop = true;
        theNextTile.moved = 'S';
        countTurns(currentTile, theNextTile);
        return theNextTile;
      }
    }
  }
  if ( (currentTile.dirs[0] == 'E') || (currentTile.dirs[1] == 'E') ) {
    // writeln(format!"E");
    if (isNextTile(currentTile, currentTile.row, currentTile.col +1)) {
      if ( (currentTile.previousRow != currentTile.row) || ( currentTile.previousCol != currentTile.col +1) ) {
        theNextTile = grid[currentTile.row][currentTile.col +1];
        theNextTile.previousRow = currentTile.row;
        theNextTile.previousCol = currentTile.col;
        // writeln(format!"In E. theNextTile: %s"(theNextTile));
        theNextTile.partOfLoop = true;
        theNextTile.moved = 'E';
        countTurns(currentTile, theNextTile);
        return theNextTile;
      }
    }
  }
  if ( (currentTile.dirs[0] == 'N') || (currentTile.dirs[1] == 'N') ) {
    // writeln(format!"N");
    if (isNextTile(currentTile, currentTile.row -1, currentTile.col)) {
      if ( (currentTile.previousRow != currentTile.row -1) || ( currentTile.previousCol != currentTile.col) ) {
        theNextTile = grid[currentTile.row -1][currentTile.col];
        theNextTile.previousRow = currentTile.row;
        theNextTile.previousCol = currentTile.col;
        // writeln(format!"In N. theNextTile: %s"(theNextTile));
        theNextTile.partOfLoop = true;
        theNextTile.moved = 'N';
        countTurns(currentTile, theNextTile);
        return theNextTile;
      }
    }
  }
  assert(0);
}

void noLoopInsideAntiClockwise(Tile current) {
  // writeln(format!"noLoopInside: current: %s"(current));
  char c = current.c;
  if (c == '|') {
    if (current.previousRow < current.row) {
      markInside(current.row, current.col -1);
    } else {
      markInside(current.row, current.col +1);
    }
  } else if (c == '-') {
    if (current.previousCol < current.col) {
      if (grid[current.row +1][current.col].c == '.') {
        markInside(current.row +1, current.col);
      } else {
        markInside(current.row -1, current.col);
      }
    }
  } else if (c == 'L') {
    if (current.previousRow < current.row) {
      markInside(current.row, current.col -1);
      markInside(current.row +1, current.col);
    }
  } else if (c == 'J') {
    if (current.previousRow < current.row) {
      markInside(current.row, current.col +1);
      markInside(current.row +1, current.col);
    }
  } else if (c == '7') {
    // writeln(format!"In noLoopInsideAntiClockwise - found 7. current tile: %s"(current));
    if (current.previousRow > current.row) {
    } else {
      markInside(current.row, current.col +1);
      markInside(current.row -1, current.col);
    }
  } else if (c == 'F') {
    if (current.previousRow < current.row) {
    } else {
      markInside(current.row, current.col -1);
      markInside(current.row -1, current.col);
    }
  // } else if (c == 'S') {
  //   tile.dirs = ['0', '0'];
  //   start = &tile;
  // } else if (c == '.') {
  //   tile.dirs = ['0', '0'];
  } else {
    throw new Exception(format!"Uknown pipe connector: %s at row: %s, col: %s"(c, current.row, current.col));
  }
}

void noLoopInsideClockwise(Tile current) {
  // writeln(format!"noLoopInside: current: %s"(current));
  char c = current.c;
  if (c == '|') {
    if (current.previousRow < current.row) {
      markInside(current.row, current.col +1);
    } else {
      markInside(current.row, current.col -1);
    }
  } else if (c == '-') {
    if (current.previousCol < current.col) {
      markInside(current.row -1, current.col);
    } else {
      markInside(current.row +1, current.col);
    }
  } else if (c == 'L') {
    if (current.previousRow < current.row) {
    } else {
      markInside(current.row +1, current.col);
      markInside(current.row, current.col -1);
    }
  } else if (c == 'J') {
    if (current.previousRow < current.row) {
      markInside(current.row, current.col +1);
      markInside(current.row +1, current.col);
    }
  } else if (c == '7') {
    if ( (current.col < grid[0].length - 1) && (grid[current.row][current.col +1].dc == '.') ) {
      writeln(format!"In noLoopInsideClockwise. current tile: %s"(current));
    }
    if (current.previousCol < current.col) {
      markInside(current.row -1, current.col);
      markInside(current.row, current.col +1);
    }
  } else if (c == 'F') {
    if (current.previousCol > current.col) {
    } else {
      markInside(current.row , current.col -1);
      markInside(current.row -1, current.col);
    }
  // } else if (c == 'S') {
  //   tile.dirs = ['0', '0'];
  //   start = &tile;
  // } else if (c == '.') {
  //   tile.dirs = ['0', '0'];
  } else {
    throw new Exception(format!"Uknown pipe connector: %s at row: %s, col: %s"(c, current.row, current.col));
  }
}

void markInside(long row, long col) {
  // writeln(format!"markInside: row: %s, col: %s"(row, col));
  if (row > 0) {
    if (row < grid.length) {
      if (col > 0) {
        if (col < grid[0].length) {
          if (!grid[row][col].partOfLoop) {
            grid[row][col].dc = '0';
            grid[row][col].isInside = true;
          }
        }
      }
    }
  } 
}

void countTurns(Tile from, Tile to) {
  if ( (from.moved == 'N') && (to.moved == 'E') ) {turns += 1;}
  else if ( (from.moved == 'E') && (to.moved == 'S') ) {turns += 1;}
  else if ( (from.moved == 'S') && (to.moved == 'W') ) {turns += 1;}
  else if ( (from.moved == 'W') && (to.moved == 'N') ) {turns += 1;}
  else if ( (from.moved == 'N') && (to.moved == 'W') ) {turns -= 1;}
  else if ( (from.moved == 'W') && (to.moved == 'S') ) {turns -= 1;}
  else if ( (from.moved == 'S') && (to.moved == 'E') ) {turns -= 1;}
  else if ( (from.moved == 'E') && (to.moved == 'N') ) {turns -= 1;}
  else {
    // throw new Exception(format!"Unvalid turn rotation- from: %s, to: %s"(from, to));
  }
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

