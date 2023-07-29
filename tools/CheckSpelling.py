import sys
import re
from textblob import TextBlob

def find_replaced_words(original_blob, corrected_blob):
    original_words = original_blob.words
    corrected_words = corrected_blob.words
    replaced_words = {}

    for original_word, corrected_word in zip(original_words, corrected_words):
        if original_word.lower() != corrected_word.lower():
            replaced_words[original_word] = corrected_word

    return replaced_words

def spell_check(input_string):
    original_blob = TextBlob(input_string)
    corrected_blob = original_blob.correct()
    replaced_words = find_replaced_words(original_blob, corrected_blob)

    return corrected_blob, replaced_words

def main():
    if len(sys.argv) != 2:
        print("Usage: python SpellCheck.py <string>")
        return

    input_string = sys.argv[1]
    corrected_text, replaced_words = spell_check(input_string)

    if not replaced_words:
        print("No misspelled words found.")
    else:
        print("Misspelled words:")
        for original_word, corrected_word in replaced_words.items():
            print(f"    * {original_word} -> {corrected_word}")

        print("\n" + str(corrected_text))

if __name__ == "__main__":
    main()
