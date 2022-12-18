# zig-wasm-string-test

A minimal Web Assembly example of string handling, built from [zig-wasm-test](https://github.com/meheleventyone/zig-wasm-test).

## Building

This project was developed using zig 0.10.0.

```
zig build
```

You need to move the resulting wasmtest.wasm file from /zig-cache/ to /www/. One has been committed if you're happy omitting this step.

## Running

Start the web server of your choice serving the www folder (e.g. `python3 -m http.server 8080`) and navigate to wasmtest.html in your browser of choice. You should see two lines:

```
hello
hellohello
```

The former is used as the input to a zig function which doubles and its input.  The latter is the output of said function.
