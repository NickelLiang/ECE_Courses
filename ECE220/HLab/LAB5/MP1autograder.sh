#!/bin/bash

#Function: Initialize test environment
load_module () {
	if module load lc3tools; then
		#Compile test cases
		compile_files "testone.asm" > /dev/null
		compile_files "testtwo.asm" > /dev/null
		compile_files "testthree.asm" > /dev/null
		return 0
	else
		return 1
	fi
}

#Function: Compile first argument
compile_files () {
	if lc3as "$1"; then
		return 0
	else
		return 1
	fi
}

#Function: Compare if two files are the same
compare () {
	# -I Ensures that register different is ignored
	# Since we only want to make sure histogram is the same
	if diff -I 'R0.*' "$1" "$2"; then
		return 0
	else
		return 1
	fi
}

#Function: Print test result
print_score () {
	echo "Grade"
	echo "******"
	echo "Functionality: $score/90"
}

#Function: Main function
main () {
	#Full Score is 90
	score=90

	#Check Compile Result
	echo "Compilation Results:"
	echo "********************"
	if ! compile_files "prog1.asm"; then
		score=$((score-90)) #If the file fail to compile, student get 0.
		print_score ""
		exit 2
	fi
	echo

	#Check Test Case 1
	echo "Test Case 1"
	cp ../../../testone.obj ./ #Copy our test case file to student folder.
	cp ../../../testone.sym ./
	lc3sim -s ../../../runtestone > studentoutone
	cat studentoutone #Print output
	if ! compare "studentoutone" "../../../testoneout"; then
		score=$((score-30)) #If the result is not the same, deduct 1/3 of full score.
	fi
	rm studentoutone #Remove test case and generated file from student folder.
	rm testone.obj
	rm testone.sym
	echo

	#Check Test Case 2
	echo "Test Case 2"
	cp ../../../testtwo.obj ./
	cp ../../../testtwo.sym ./
	lc3sim -s ../../../runtesttwo > studentouttwo
	cat studentouttwo
	if ! compare "studentouttwo" "../../../testtwoout"; then
		score=$((score-30))
	fi
	rm studentouttwo
	rm testtwo.obj
	rm testtwo.sym
	echo

	#Check Test Case 3
	echo "Test Case 3"
	cp ../../../testthree.obj ./
	cp ../../../testthree.sym ./
	lc3sim -s ../../../runtestthree > studentoutthree
	cat studentoutthree
	if ! compare "studentoutthree" "../../../testthreeout"; then
		score=$((score-30))
	fi
	rm studentoutthree
	rm testthree.obj
	rm testthree.sym
	echo

	#Print result
	print_score ""
}

##################################################
#Load LC3 Modules
if ! load_module ""; then
	echo "Fail to Load Modules."
	exit 1
fi

#Load student list
mapfile -t studentArray < studentlist

#Go over the student list
for (( i = 0 ; i < ${#studentArray[@]} ; i++))
do
	cd ${studentArray[$i]} #Get into student folder
	cd ./ece220/MP1 #Get into MP1 folder
	main "" | tee grade.txt #Go over main, generate grade.txt in their folder
	cd ../../../ #Come back to our folder
done

