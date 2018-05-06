###Run the Script###
The bash script file is "MP1autograder.sh"
The student netid list is "studentlist"
To execute, I simply use "$ sh MP1autograder.sh"

###Script Function###
In the script file, I managed to read the studentlist into an array,
and the autograder go over that array, test each student's program,
and put a "grade.txt" in their folder.

###Score Breakdown###
The full grade is 90, since according to the MP1 rubric there's 10 
points for style and comment.
- If student's program failed to compile, they get 0.
- For each test case, student earn 30 points.

###Test Case###
I also included two sample in this LAB folder. Each folder has similar
structure as our svn, the MP1 is in <netid>/ece220/MP1.
The first student, zuodong2, has a full-score program.
For the second student, nickel2, his program cannot compile, so he will
receive zero score.

/*
 * Nickel Liang, 10/18/2017
 * ECE 220 Honor Lab 5
 * zuodong2@illinois.edu
 */
