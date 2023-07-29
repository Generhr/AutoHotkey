import sys

KNOWN_ACRONYMS = ["IDE", "lol", "etc"]  # Add other known acronyms here if needed

def title_case(title):
    minor_words = ["a", "an", "the", "and", "but", "or", "on", "in", "with", "of", "to"]
    words = title.lower().split()
    title_cased_words = [word.capitalize() if word not in minor_words or word in KNOWN_ACRONYMS else word for word in words]
    title_cased_words[0] = title_cased_words[0].capitalize()
    title_cased_words[-1] = title_cased_words[-1].capitalize()
    return " ".join(title_cased_words)

def main():
    if len(sys.argv) != 2:
        print("Usage: python capatalise.py <string>")
        return

    input_string = sys.argv[1]
    result = title_case(input_string)

    # Write the modified string to the standard output
    sys.stdout.write(result)

if __name__ == "__main__":
    main()
