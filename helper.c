/*
 * Jon Woods
 * SE98699
 * The following program provides helper functions for storing the input of the ASM Caesar Cipher as
 * a C-string of arbitrary length. It is taken directly from sample code "memfuncs.c" provided to us
 * on Blackboard but condensed with more personally useful comments.
 */

#include <stdbool.h> // Allows "true" for the input loop
#include <stdlib.h>  // Allows reallocation and freeing of memory
#include <stdio.h>   // Allows reception of user input through getchar()
#include <assert.h>  // Allows use of assert() for C-string validation

char* getInput() {
  char* inputString = malloc(sizeof(char));
  assert(inputString != NULL);

  int index = 0;
  while(true) {
    char input = getchar();
    // Stop reading new characters when user presses Enter key
    if(input == EOF || input == '\n') {
      inputString[index] = '\0';
      return inputString;
    }

    // Add any other input key to the C-string and reallocate memory
    inputString[index] = input;
    index += 1;
    inputString = realloc(inputString, sizeof(char) * (index + 1)); // Increase memory by one byte
    assert(inputString != NULL);
  }
}

// Receives a C-string and deallocates its memory
void freeMem(char* buffer) {
  free(buffer);
}
