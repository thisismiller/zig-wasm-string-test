// just keep a global ref to the instance around for convenience
var instance;

function encodeString(instance, string) {
  const buffer = new TextEncoder().encode(string);
  // `double` takes a [*]u8, so no need for length+1 for a null byte.
  const pointer = instance.exports.alloc(buffer.length);
  const slice = new Uint8Array(
    instance.exports.memory.buffer,
    pointer,
    buffer.length
  );
  slice.set(buffer);
  return [pointer, buffer.length];
};

function decodeString(instance, ptrZ) {
  const dv = new DataView(instance.exports.memory.buffer);
  var length = 0;
  while (dv.getUint8(ptrZ + length)) {
    length += 1;
  }

  const slice = new Uint8Array(
    instance.exports.memory.buffer,
    ptrZ,
    length
  );
  return new TextDecoder().decode(slice);
};

// define our imports
var imports = {
    env: {
    }
};

// do the thing
fetch("wasmtest.wasm")
    .then(function (response) { return response.arrayBuffer(); })
    .then(function (bytes) { return WebAssembly.instantiate(bytes, imports); })
    .then(function (results) {
    instance = results.instance;

    // Docs say that this should be automatically called, but that appears
    // to not be true.
    instance.exports.start();

    // Fetch a JS string, and convert it into a slice for zig.
    let input_text = document.getElementById("input").textContent;
    let [in_ptr, in_len] = encodeString(instance, input_text);

    // Invoke the function, and get a [*:0]u8 in return.
    let out_ptr = instance.exports.double(in_ptr, in_len);

    // Convert the [*:0]u8 to a JS string, and then free it from zig's memory.
    let out_str = decodeString(instance, out_ptr);
    instance.exports.free(out_ptr, out_str.length);

    // Put the output back into the document.
    document.getElementById("output").textContent = out_str;
});
