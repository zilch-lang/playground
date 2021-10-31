A very simple web playground for Zilch, which allows showing both the output of the program written
as well as what N* code is generated from it.

## Running the server

This repository contains a web app written mostly in Purescript.
You will need to have `npm`, `purs` and `spago` installed.
You may refer to the links below to install these:
- `npm`: https://docs.npmjs.com/getting-started/
- `purs`: https://github.com/purescript/documentation/blob/master/guides/Getting-Started.md
- `spago`: https://github.com/purescript/spago#installation

When all the tools are installed, you will simply need to build this project
(refer to the documentation of spago to know how to).

The server requires no command-line arguments in order to run, but you may specify these:
- `--port, -p <INT>`: the integer used as the port number the server will connect to. Defaults to `8080` if not specified.
- `--out, -o <DIR>`: the directory used to store temporary files (mainly compilation junk). Defaults to `./out`.
- `--with-gzc <EXEC>`: specify the path (or the name) to the executable which will be used to compile the Zilch code. Defaults to `gzc` which must be found in the `PATH`.
- `--with-gcc <EXEC>`: specify the path (or the name) to the executable used to link all generated objects together. Defaults to `gcc`.

## License

This repository is licensed under the terms of the [MIT license](./LICENSE).
