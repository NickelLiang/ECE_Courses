/**
 * @file cartalk_puzzle.cpp
 * Holds the function which solves a CarTalk puzzler.
 *
 * @author Matt Joras
 * @date Winter 2013
 */

#include <fstream>
#include <iostream>
#include <string>

#include "cartalk_puzzle.h"

using namespace std;


/**
 * Solves the CarTalk puzzler described here:
 * http://www.cartalk.com/content/wordplay-anyone.
 * @return A vector of (string, string, string) tuples
 * Returns an empty vector if no solutions are found.
 * @param d The PronounceDict to be used to solve the puzzle.
 * @param word_list_fname The filename of the word list to be used.
 */
vector<std::tuple<std::string, std::string, std::string>> cartalk_puzzle(PronounceDict d,
                                    const string& word_list_fname)
{
    vector<std::tuple<std::string, std::string, std::string>> ret;

    /* Read in the word list */
    ifstream wordsFile(word_list_fname);
    string word;
    if (wordsFile.is_open()) {
        /* Reads a line from `wordsFile` into `word` until the file ends. */
        while (getline(wordsFile, word)) {
            // cout << word << endl;
            if (word.length() > 2) {
                string first = word.substr(1, word.length() - 1);
                string second = word[0] + word.substr(2, word.length() - 1);
                if (d.homophones(word, first) && d.homophones(word, second) && d.homophones(first, second)) {
                    ret.push_back(std::make_tuple(word, first, second));
                    // cout << word << " " << first << " " << second << endl;
                }
            }

        }
    }
    return ret;
}
