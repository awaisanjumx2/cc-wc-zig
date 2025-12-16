# cc-wc-zig

A Zig implementation of the Unix `wc` (word count) command-line tool.

## About

This project is a solution to the [Coding Challenges - Build Your Own wc Tool](https://codingchallenges.fyi/challenges/challenge-wc) challenge. The goal is to recreate the functionality of the classic Unix `wc` utility, which counts lines, words, and bytes in files.

## Implementation

This implementation is written in **Zig**, a general-purpose programming language designed for robustness, optimality, and maintainability.

## Features

- Count bytes (`-c`)
- Count lines (`-l`)
- Count words (`-w`)
- Support for reading from files or standard input
- Compatible output format with the original `wc` command

## Building

Make sure you have [Zig](https://ziglang.org/download/) installed on your system.

```bash
zig build
```

The compiled binary will be available at `zig-out/bin/cc_wc_zig`.

## Usage

```bash
# Count lines, words, and bytes
./zig-out/bin/cc_wc_zig test.txt

# Count lines only
./zig-out/bin/cc_wc_zig -l test.txt

# Count words only
./zig-out/bin/cc_wc_zig -w test.txt

# Count bytes only
./zig-out/bin/cc_wc_zig -c test.txt

# Read from standard input
cat test.txt | ./zig-out/bin/cc_wc_zig -l
```

## Project Structure

```
cc-wc-zig/
├── src/
│   ├── main.zig      # Main entry point
│   └── utils.zig     # Utility functions
├── build.zig         # Build configuration
├── build.zig.zon     # Build dependencies
└── README.md         # This file
```

## License

This is a learning project created as part of the [Coding Challenges](https://codingchallenges.fyi/) series.
