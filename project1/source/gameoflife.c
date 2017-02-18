// gameoflife.c
// Name: Weixiang Fang
// JHED: wfang9

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include "mpi.h"

// #include <unistd.h>

#define DEFAULT_ITERATIONS 64
#define GRID_WIDTH  256
#define DIM  16     // assume a square grid

int main ( int argc, char** argv ) {

  int global_grid[ 256 ] = 
   {0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,
    1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };

  // MPI Standard variable
  int num_procs;
  int ID, j;
  int iters = 0;
  int num_iterations;

  // Setup number of iterations
  if (argc == 1) {
    num_iterations = DEFAULT_ITERATIONS;
  }
  else if (argc == 2) {
    num_iterations = atoi(argv[1]);
  }
  else {
    printf("Usage: ./gameoflife <num_iterations>\n");
    exit(1);
  }

  // Messaging variables
  MPI_Status stat;

  // MPI Setup
  if ( MPI_Init( &argc, &argv ) != MPI_SUCCESS )
  {
    printf ( "MPI_Init error\n" );
  }

  MPI_Comm_size ( MPI_COMM_WORLD, &num_procs ); // Set the num_procs
  MPI_Comm_rank ( MPI_COMM_WORLD, &ID );

  assert ( DIM % num_procs == 0 );
  
  // Decalre variables
  int i, row, col, prevRow, nextRow, prevCol, nextCol;
  // Initialize local copy of data
  int proc_size = GRID_WIDTH / num_procs;
  int procArray[proc_size], procArrayNew[proc_size];

  for (i = 0; i < proc_size; i++) {
      procArray[i] = global_grid[ID * proc_size + i];
      procArrayNew[i] = procArray[i];
  }

  // Declare variables
  int prev, next;
  prev = (ID == 0) ? (num_procs - 1) : (ID - 1);
  next =  (ID + 1) % num_procs;

  int fromPrev[DIM], fromNext[DIM], toPrev[DIM], toNext[DIM];
  for (iters = 0; iters < num_iterations; iters++) {

    // Messages to be sent
    for (i = 0; i < DIM; i++) {
        toPrev[i] = procArray[i];
        toNext[i] = procArray[proc_size - DIM + i];
    }

    // Message passing:
    // Processes form a ring, each process passes to and receives message from neighbors
    // Tag 1 messages pass down, Tag 2 messages pass up
    if (ID % 2 == 0) {
        // Even processes send first
        MPI_Send(&toNext, DIM, MPI_INT, next, 1, MPI_COMM_WORLD);
        MPI_Recv(&fromPrev, DIM, MPI_INT, prev, 1, MPI_COMM_WORLD, &stat);
        MPI_Send(&toPrev, DIM, MPI_INT, prev, 2, MPI_COMM_WORLD);
        MPI_Recv(&fromNext, DIM, MPI_INT, next, 2, MPI_COMM_WORLD, &stat);
    } else {
        // Odd processes receive first
        MPI_Recv(&fromPrev, DIM, MPI_INT, prev, 1, MPI_COMM_WORLD, &stat);
        MPI_Send(&toNext, DIM, MPI_INT, next, 1, MPI_COMM_WORLD);
        MPI_Recv(&fromNext, DIM, MPI_INT, next, 2, MPI_COMM_WORLD, &stat);
        MPI_Send(&toPrev, DIM, MPI_INT, prev, 2, MPI_COMM_WORLD);
    }
    
    // Iterate over all cells in local array
    for (i = 0; i < proc_size; i++) {

        int neighborCnt = 0;

        row = i / DIM;
        col = i % DIM;
        prevCol = col == 0 ? DIM - 1 : col - 1;
        nextCol = (col + 1) % DIM;

        // Count the same row
        neighborCnt += procArray[row * DIM + prevCol] +
            procArray[row * DIM + nextCol];

        // Count the previous row
        if (row == 0) {
            neighborCnt += fromPrev[col] +
                fromPrev[prevCol] +
                fromPrev[nextCol];
        } else {
            prevRow = row - 1;
            neighborCnt += procArray[prevRow * DIM + col] +
                procArray[prevRow * DIM + prevCol] +
                procArray[prevRow * DIM + nextCol];
        }

        // Count the next row
        if ((row + 1) * DIM >= proc_size) {
            neighborCnt += fromNext[col] +
                fromNext[prevCol] +
                fromNext[nextCol];
        } else {
            nextRow = row + 1;
            neighborCnt += procArray[nextRow * DIM + col] + 
                procArray[nextRow * DIM + prevCol] + 
                procArray[nextRow * DIM + nextCol];
        }
     
        // Calculate new states from counts
        if (procArray[i] == 0 && neighborCnt == 3) {
            procArrayNew[i] = 1;
        } else if (procArray[i] == 1 && (neighborCnt < 2 | neighborCnt > 3)) {
            procArrayNew[i] = 0;
        }
    }

    // Gather results to process 0 and update global_grid
    MPI_Gather(procArrayNew, proc_size, MPI_INT, global_grid, proc_size, MPI_INT, 0, MPI_COMM_WORLD);

    // Update local array with the new states
    for (i = 0; i < proc_size; i++) {
        procArray[i] = procArrayNew[i];
    }

    // Output the updated grid state
    if ( ID == 0 ) {
        printf ( "\nIteration %d: final grid:\n", iters );
        for ( j = 0; j < GRID_WIDTH; j++ ) {
            if ( j % DIM == 0 ) {
                printf( "\n" );
            }
            printf ( "%d  ", global_grid[j] );
        }
        printf( "\n" );
        // printf("\033[19A");
        // sleep(1);
    }
  }

  // TODO: Clean up memory
  MPI_Finalize(); 
}
