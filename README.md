# CSS-mini-mini-mini

> CSS (almost) remynifier

[![npmjs.org version](https://img.shields.io/npm/v/css-mini-mini-mini)](https://www.npmjs.com/package/css-mini-mini-mini)

<!-- toc -->

- [About](#about)
  - [Features](#features)
  - [Benchmark](#benchmark)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

<!-- tocstop -->

## About

(Let me introduce some theory first).
In the past, there was this great article <https://luisant.ca/remynifier> by
_Remy Luisan_ which introduced the idea of running multiple CSS minifiers on the
same \[style\] file \[in serial\] to get better minification results than any
single CSS minifier achieves on it's own.
Somewhat crazy idea, but I liked the results.

This project takes the article's general idea and implements it for NodeJS.
All CSS minifiers \(_cleancss_, _cssnano_, _csso_ and _crass_\) are included as
npm dependencies, so can you are good to go right of the bat.

Currently there a few bells and whistles missing.
For example, current algorithm is basically greedy and only considers the best
branch.
This means it does not always find the optimal solution...
although it might be close enough ¯\\_(ツ)_/¯.

### Features

- 💻 Usable as a CLI
- 📦 Installable as _[npm package](https://www.npmjs.com/package/css-mini-mini-mini)_
- 📂 Reading files or stdin
- 🗳 Writing files or stdout
- 🎁 Self contained with all minifiers as direct dependencies

### Benchmark

I haven't done any exhaustive benchmarks yet.
The only comparison I have is from the CSS on my
personal webpage at <https://github.com/matejkosiarcik/matejkosiarcik.com>.

| \-                   | CSS size \[B\] | possible gain \[%\] |
| -------------------- | -------------- | ------------------- |
| Original             | 18415          | 63.29               |
| _crass_              | 10926          | 38.14               |
| _cleancss_           | 10275          | 34.22               |
| _csso_               | 9569           | 29.37               |
| _cssnano_            | 7795           | 12.29               |
| _css-mini-mini-mini_ | 6759           | -                   |

As we can see, css-mini-mini-mini can gain between _12%_ and _38%_ over a single
minifier.

## Installation

```sh
npm install --save-dev css-mini-mini-mini
```

## Usage

```sh
$ cmmm input.css -o output.css
# or
$ cmmm <input.css >output.css
```

When in doubt, get help:

```sh
$ cmmm --help
cmmm [file] [options...]

General description...

Positionals:
  file  Input file path (- for stdin)                    [string] [default: "-"]

Options:
  -h, --help     Show usage                                            [boolean]
  -V, --version  Show current version                                  [boolean]
  -o, --output   Output file path (- for stdout)         [string] [default: "-"]
  -v, --verbose  Verbose logging                                       [boolean]
```

## License

The project is licensed under MIT License.
See [LICENSE](./LICENSE.txt) for full details.
