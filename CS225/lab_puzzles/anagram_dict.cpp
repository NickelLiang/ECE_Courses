/**
 * @file anagram_dict.cpp
 * Implementation of the AnagramDict class.
 *
 * @author Matt Joras
 * @date Winter 2013
 */

#include "anagram_dict.h"

#include <algorithm> /* I wonder why this is included... */
#include <fstream>
#include <iostream>
#include <string>

using std::string;
using std::vector;
using std::ifstream;
using std::cout;
using std::endl;
using std::sort;

/**
 * Constructs an AnagramDict from a filename with newline-separated
 * words.
 * @param filename The name of the word list file.
 */
AnagramDict::AnagramDict(const string& filename)
{
    /* Read in the word list */
    ifstream wordsFile(filename);
    string word;
    if (wordsFile.is_open()) {
        /* Reads a line from `wordsFile` into `word` until the file ends. */
        while (getline(wordsFile, word)) {
            string sorted = word;
            sort(sorted.begin(), sorted.end());
            // cout << word << " " << sorted << endl;
            dict[sorted].push_back(word);
        }
    }
}

/**
 * Constructs an AnagramDict from a vector of words.
 * @param words The vector of strings to be used as source words.
 */
AnagramDict::AnagramDict(const vector<string>& words)
{
    for (size_t i = 0; i < words.size(); i++) {
        string sorted = words[i];
        sort(sorted.begin(), sorted.end());
        // cout << words[i] << " " << sorted << endl;
        dict[sorted].push_back(words[i]);
    }
}

/**
 * @param word The word to find anagrams of.
 * @return A vector of strings of anagrams of the given word. Empty
 * vector returned if no anagrams are found or the word is not in the
 * word list.
 */
vector<string> AnagramDict::get_anagrams(const string& word) const
{
    string sorted = word;
    sort(sorted.begin(), sorted.end());
    for (const std::pair<const std::string, std::vector<std::string>> & words : dict) {
        if (words.first == sorted) {
            return words.second;
        }
    }
    return vector<string>(); //error
}

/**
 * @return A vector of vectors of strings. Each inner vector contains
 * the "anagram siblings", i.e. words that are anagrams of one another.
 * NOTE: It is impossible to have one of these vectors have less than
 * two elements, i.e. words with no anagrams are ommitted.
 */
vector<vector<string>> AnagramDict::get_all_anagrams() const
{
    vector<vector<string>> ret;
    for (const std::pair<const std::string, std::vector<std::string>> & words : dict) {
        vector<string> temp = get_anagrams(words.first);
        if (temp.size() >= 2) {
            ret.push_back(temp);
        }
    }
    return ret;
}
