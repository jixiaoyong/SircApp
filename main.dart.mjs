// Compiles a dart2wasm-generated main module from `source` which can then
// be instantiated via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string'], importedStringConstants: ''};
  return new CompiledApp(
      await _compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm module from `bytes` which is then
// instantiable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string'], importedStringConstants: ''};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

let _isCompileStreamingSupported;
async function _compileStreaming(source, builtins) {
  _isCompileStreamingSupported ??= WebAssembly.compileStreaming(
    new Response(
      new Uint8Array([0,97,115,109,1,0,0,0,1,4,1,96,0,0,2,23,1,14,119,97,115,109,58,106,115,45,115,116,114,105,110,103,4,99,97,115,116,0,0]),
      {headers: {'Content-Type': 'application/wasm'}},
    ),
    builtins,
  ).then(() => false, (e) => e instanceof WebAssembly.CompileError);
  if (await _isCompileStreamingSupported) {
    return WebAssembly.compileStreaming(source, builtins);
  }
  return WebAssembly.compile(await (await source).arrayBuffer(), builtins);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arguments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `use-load-ids` option is passed. Each load ID maps to
  //   one or more wasm files as specified in the emitted JSON file. It also
  //   takes a callback that should be invoked for each loaded module with 2
  //   arguments: (1) the module name, (2) the loaded module in a format
  //   supported by `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  //   The callback returns a Promise that resolves when the module is
  //   instantiated.
  //   loadDeferredId should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports, {loadDeferredModules, loadDeferredId} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            AB: b => !!b,
      AC: Function.prototype.call.bind(DataView.prototype.setUint16),
      AD: x0 => x0.tabIndex,
      AE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      AF: x0 => x0.identifier,
      AG: x0 => x0.first(),
      AH: (x0,x1) => x0.querySelectorAll(x1),
      AI: x0 => x0.offsetHeight,
      AJ: x0 => x0.displayHeight,
      AK: x0 => x0.imageBitmaps,
      B: s => printToConsole(s),
      BB: () => globalThis.document,
      BC: Function.prototype.call.bind(DataView.prototype.setUint8),
      BD: (x0,x1) => x0.contains(x1),
      BE: x0 => x0.matches,
      BF: x0 => x0.touches,
      BG: x0 => x0.next(),
      BH: (x0,x1) => x0.removeProperty(x1),
      BI: x0 => x0.offsetWidth,
      BJ: x0 => x0.displayWidth,
      BK: x0 => x0.canvasKitMaximumSurfaces,
      C: Function.prototype.call.bind(Number.prototype.toString),
      CB: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      CC: Function.prototype.call.bind(DataView.prototype.setInt8),
      CD: x0 => x0.activeElement,
      CE: (x0,x1) => x0.matchMedia(x1),
      CF: x0 => x0.pressure,
      CG: x0 => x0.current(),
      CH: (x0,x1) => x0.add(x1),
      CI: x0 => x0.stopPropagation(),
      CJ: x0 => x0.duration,
      CK: x0 => x0.nextSibling,
      D: Function.prototype.call.bind(BigInt.prototype.toString),
      DB: (x0,x1) => x0.focus(x1),
      DC: Function.prototype.call.bind(DataView.prototype.getInt8),
      DD: x0 => x0.parentNode,
      DE: x0 => x0.matches,
      DF: x0 => x0.tiltY,
      DG: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      DH: x0 => x0.data,
      DI: x0 => x0.disabled,
      DJ: (x0,x1) => ({frameIndex: x0,completeFramesOnly: x1}),
      DK: (x0,x1) => x0.debug(x1),
      E: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      EB: () => ({}),
      EC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      ED: x0 => x0.tagName,
      EE: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      EF: x0 => x0.tiltX,
      EG: x0 => x0.v8BreakIterator,
      EH: (x0,x1) => x0.removeAttribute(x1),
      EI: (x0,x1) => { x0.min = x1 },
      EJ: (x0,x1) => x0.decode(x1),
      EK: x0 => x0.hostElement,
      F: () => new Error().stack,
      FB: (o, p, v) => o[p] = v,
      FC: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      FD: x0 => x0.target,
      FE: f => f.dartFunction,
      FF: x0 => x0.pointerType,
      FG: () => globalThis.Intl,
      FH: (x0,x1) => { x0.value = x1 },
      FI: (x0,x1) => { x0.max = x1 },
      FJ: x0 => x0.image,
      FK: x0 => x0.location,
      G: s => JSON.stringify(s),
      GB: () => [],
      GC: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      GD: x0 => x0.clientY,
      GE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      GF: x0 => x0.pointerId,
      GG: (x0,x1) => x0.segment(x1),
      GH: (x0,x1) => { x0.value = x1 },
      GI: (x0,x1) => { x0.disabled = x1 },
      GJ: x0 => x0.close(),
      GK: (x0,x1) => x0.getModifierState(x1),
      H: Function.prototype.call.bind(Number.prototype.toString),
      HB: (a, i) => a.push(i),
      HC: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      HD: x0 => x0.clientX,
      HE: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      HF: x0 => x0.getCoalescedEvents(),
      HG: x0 => x0.index,
      HH: x0 => x0.value,
      HI: (x0,x1) => { x0.scrollLeft = x1 },
      HJ: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      HK: x0 => x0.metaKey,
      I: Function.prototype.call.bind(String.prototype.indexOf),
      IB: x0 => new Int8Array(x0),
      IC: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      ID: (x0,x1,x2) => x0.addEventListener(x1,x2),
      IE: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      IF: s => s.trimLeft(),
      IG: x0 => x0.next(),
      IH: x0 => x0.selectionDirection,
      II: (x0,x1) => { x0.spellcheck = x1 },
      IJ: x0 => new window.ImageDecoder(x0),
      IK: x0 => x0.altKey,
      J: (s, p, i) => s.lastIndexOf(p, i),
      JB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      JC: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      JD: (x0,x1,x2) => x0.setAttribute(x1,x2),
      JE: (o, i) => o[i],
      JF: s => s.toUpperCase(),
      JG: x0 => x0.value,
      JH: x0 => x0.selectionStart,
      JI: (x0,x1) => { x0.disabled = x1 },
      JJ: x0 => x0.name,
      JK: x0 => x0.ctrlKey,
      K: o => o,
      KB: x0 => new Uint8Array(x0),
      KC: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      KD: (x0,x1) => x0.closest(x1),
      KE: o => o.length,
      KF: (x0,x1) => x0.test(x1),
      KG: x0 => x0.done,
      KH: x0 => x0.selectionEnd,
      KI: (x0,x1) => x0.getRandomValues(x1),
      KJ: x0 => x0.repetitionCount,
      KK: x0 => x0.isComposing,
      L: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      LB: x0 => new Uint8ClampedArray(x0),
      LC: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      LD: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      LE: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      LF: x0 => x0.length,
      LG: (o, m, a) => o[m].apply(o, a),
      LH: x0 => x0.value,
      LI: () => globalThis.crypto,
      LJ: x0 => x0.frameCount,
      LK: x0 => x0.code,
      M: x0 => x0.index,
      MB: x0 => new Int16Array(x0),
      MC: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      MD: (handle) => clearTimeout(handle),
      ME: x0 => x0.language,
      MF: x0 => x0.pop(),
      MG: x0 => x0.iterator,
      MH: x0 => x0.selectionDirection,
      MI: l => new DataView(new ArrayBuffer(l)),
      MJ: x0 => x0.selectedTrack,
      MK: x0 => x0.repeat,
      N: o => String(o),
      NB: x0 => new Uint16Array(x0),
      NC: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      ND: x0 => x0.maxTouchPoints,
      NE: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      NF: x0 => x0.flags,
      NG: () => globalThis.Symbol,
      NH: x0 => x0.selectionStart,
      NI: (a, i) => a.splice(i, 1),
      NJ: x0 => x0.completed,
      NK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      O: o => o === undefined,
      OB: x0 => new Int32Array(x0),
      OC: (x0,x1) => x0.querySelector(x1),
      OD: x0 => x0.platform,
      OE: () => globalThis.window.FinalizationRegistry,
      OF: (a, s) => a.join(s),
      OG: (x0,x1) => new Intl.Segmenter(x0,x1),
      OH: x0 => x0.selectionEnd,
      OI: a => a.pop(),
      OJ: x0 => x0.ready,
      OK: x0 => x0.userAgent,
      P: (x0,x1) => x0.exec(x1),
      PB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      PC: (x0,x1) => x0.item(x1),
      PD: s => new Date(s * 1000).getTimezoneOffset() * 60,
      PE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      PF: (x0,x1) => x0.error(x1),
      PG: x0 => x0.Segmenter,
      PH: (x0,x1) => { x0.name = x1 },
      PI: x0 => new WeakRef(x0),
      PJ: x0 => x0.tracks,
      PK: x0 => x0.navigator,
      Q: (x0,x1) => { x0.lastIndex = x1 },
      QB: x0 => new Uint32Array(x0),
      QC: x0 => x0.length,
      QD: Date.now,
      QE: x0 => new window.FinalizationRegistry(x0),
      QF: () => globalThis.console,
      QG: x0 => x0.buffer,
      QH: (x0,x1) => { x0.placeholder = x1 },
      QI: x0 => x0.deref(),
      QJ: () => globalThis.window.ImageDecoder,
      QK: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      R: o => o,
      RB: x0 => new Float32Array(x0),
      RC: (x0,x1) => x0.querySelectorAll(x1),
      RD: (x0,x1) => x0.contains(x1),
      RE: (x0,x1) => x0.unregister(x1),
      RF: s => s.trimRight(),
      RG: x0 => x0.wasmMemory,
      RH: (x0,x1) => { x0.autocomplete = x1 },
      RI: () => globalThis.WeakRef,
      RJ: x0 => x0.decode(),
      RK: (x0,x1) => x0.getItem(x1),
      S: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      SB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      SC: (x0,x1) => x0.getAttribute(x1),
      SD: (decoder, codeUnits) => decoder.decode(codeUnits),
      SE: x0 => x0.preventDefault(),
      SF: x0 => x0.blur(),
      SG: () => globalThis.window._flutter_skwasmInstance,
      SH: (x0,x1) => { x0.type = x1 },
      SI: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      SJ: x0 => x0.naturalHeight,
      SK: x0 => x0.localStorage,
      T: o => o instanceof RegExp,
      TB: x0 => new Float64Array(x0),
      TC: x0 => x0.remove(),
      TD: () => new TextDecoder("utf-8", {fatal: true}),
      TE: x0 => x0.parent,
      TF: x0 => x0.button,
      TG: () => new TextDecoder(),
      TH: (x0,x1) => { x0.name = x1 },
      TI: (a, s, e) => a.slice(s, e),
      TJ: x0 => x0.naturalWidth,
      TK: (x0,x1) => x0.key(x1),
      U: (string, times) => string.repeat(times),
      UB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      UC: (x0,x1) => x0.appendChild(x1),
      UD: () => new TextDecoder("utf-8", {fatal: false}),
      UE: x0 => x0.timeStamp,
      UF: (x0,x1) => x0.prepend(x1),
      UG: (map, o, v) => map.set(o, v),
      UH: (x0,x1) => { x0.placeholder = x1 },
      UI: (o, p) => p in o,
      UJ: (x0,x1) => { x0.src = x1 },
      UK: x0 => x0.length,
      V: o => o,
      VB: x0 => new ArrayBuffer(x0),
      VC: (x0,x1) => x0.append(x1),
      VD: (a, i, v) => a[i] = v,
      VE: (x0,x1) => x0.hasAttribute(x1),
      VF: x0 => x0.parentElement,
      VG: (map, o) => map.get(o),
      VH: (x0,x1) => { x0.scrollTop = x1 },
      VI: x0 => x0.groups,
      VJ: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      VK: (x0,x1) => x0.removeItem(x1),
      W: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      WB: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      WC: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      WD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      WE: x0 => x0.type,
      WF: x0 => x0.innerHeight,
      WG: () => new WeakMap(),
      WH: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      WI: (x0,x1) => { x0.border = x1 },
      WJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      WK: (x0,x1,x2) => x0.setItem(x1,x2),
      X: x0 => x0.dotAll,
      XB: (x0,x1,x2) => new DataView(x0,x1,x2),
      XC: x0 => x0.style,
      XD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      XE: (x0,x1) => x0.getModifierState(x1),
      XF: x0 => x0.innerWidth,
      XG: (d, digits) => d.toFixed(digits),
      XH: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      XI: (x0,x1) => { x0.height = x1 },
      XJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      XK: (x0,x1) => x0.querySelector(x1),
      Y: x0 => x0.unicode,
      YB: (o, p) => o[p],
      YC: x0 => x0.debugShowSemanticsNodes,
      YD: (s) => +s,
      YE: x0 => x0.buttons,
      YF: x0 => x0.height,
      YG: x0 => x0.maxHeight,
      YH: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      YI: (x0,x1) => { x0.width = x1 },
      YJ: x0 => x0.send(),
      YK: (x0,x1) => x0.append(x1),
      Z: x0 => x0.ignoreCase,
      ZB: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      ZC: (x0,x1) => x0.warn(x1),
      ZD: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      ZE: x0 => x0.ctrlKey,
      ZF: x0 => x0.width,
      ZG: x0 => x0.maxWidth,
      ZH: x0 => x0.keyCode,
      ZI: x0 => x0.style,
      ZJ: x0 => x0.status,
      ZK: x0 => x0.body,
      a: x0 => x0.multiline,
      aB: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      aC: x0 => x0.console,
      aD: s => s.trim(),
      aE: x0 => x0.getBoundingClientRect(),
      aF: x0 => x0.clientHeight,
      aG: x0 => x0.minHeight,
      aH: (x0,x1) => x0.scrollIntoView(x1),
      aI: (x0,x1) => { x0.id = x1 },
      aJ: x0 => x0.response,
      aK: () => globalThis.removeSplashFromWeb(),
      b: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      bB: o => o.byteOffset,
      bC: () => globalThis.window,
      bD: x0 => x0.classList,
      bE: x0 => x0.y,
      bF: x0 => x0.clientWidth,
      bG: x0 => x0.minWidth,
      bH: x0 => x0.multiViewEnabled,
      bI: (x0,x1) => x0.createElement(x1),
      bJ: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      bK: x0 => x0.extraAssets,
      c: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      cB: o => o.buffer,
      cC: (o, c) => o instanceof c,
      cD: x0 => x0.relatedTarget,
      cE: x0 => x0.x,
      cF: x0 => x0.isConnected,
      cG: x0 => x0.debugSkipFontRetryDelay,
      cH: (x0,x1) => x0.replaceWith(x1),
      cI: () => globalThis.document,
      cJ: (x0,x1) => { x0.responseType = x1 },
      cK: x0 => x0.fontManifest,
      d: (x0,x1) => x0.didCreateEngineInitializer(x1),
      dB: Function.prototype.call.bind(DataView.prototype.getUint8),
      dC: (string, token) => string.split(token),
      dD: x0 => x0.hasFocus(),
      dE: x0 => x0.top,
      dF: x0 => x0.head,
      dG: x0 => x0.status,
      dH: (x0,x1) => { x0.className = x1 },
      dI: x0 => x0.id,
      dJ: () => new XMLHttpRequest(),
      dK: x0 => x0.assetManifest,
      e: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      eB: (b, o) => new DataView(b, o),
      eC: o => o instanceof Array,
      eD: x0 => x0.shiftKey,
      eE: x0 => x0.left,
      eF: (x0,x1) => { x0.content = x1 },
      eG: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      eH: (x0,x1) => { x0.tabIndex = x1 },
      eI: (x0,x1) => x0.get(x1),
      eJ: x0 => x0.tee(),
      eK: x0 => x0.buildConfig,
      f: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      fB: (b, o, l) => new DataView(b, o, l),
      fC: (a, i) => a[i],
      fD: x0 => x0.body,
      fE: x0 => x0.scrollTop,
      fF: (x0,x1) => { x0.name = x1 },
      fG: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      fH: (x0,x1) => { x0.action = x1 },
      fI: x0 => x0.text(),
      fJ: x0 => x0.getReader(),
      fK: (x0,x1) => new OffscreenCanvas(x0,x1),
      g: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      gB: Function.prototype.call.bind(DataView.prototype.getFloat64),
      gC: a => a.length,
      gD: x0 => x0.visibilityState,
      gE: x0 => x0.offsetTop,
      gF: (x0,x1) => x0.removeChild(x1),
      gG: (x0,x1,x2) => x0.set(x1,x2),
      gH: (x0,x1) => { x0.method = x1 },
      gI: x0 => x0.headers,
      gJ: x0 => x0.length,
      gK: x0 => x0.assetBase,
      h: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      hB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      hC: x0 => x0.userAgent,
      hD: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      hE: x0 => x0.scrollLeft,
      hF: x0 => x0.firstChild,
      hG: x0 => x0.arrayBuffer(),
      hH: (x0,x1) => { x0.noValidate = x1 },
      hI: (x0,x1,x2,x3) => ({method: x0,headers: x1,body: x2,credentials: x3}),
      hJ: x0 => x0.value,
      hK: x0 => x0.loader,
      i: x0 => new Promise(x0),
      iB: Function.prototype.call.bind(DataView.prototype.setFloat64),
      iC: x0 => x0.navigator,
      iD: (a, l) => a.length = l,
      iE: x0 => x0.offsetLeft,
      iF: x0 => x0.viewConstraints,
      iG: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      iH: x0 => x0.click(),
      iI: (x0,x1,x2) => x0.fetch(x1,x2),
      iJ: x0 => x0.done,
      iK: () => globalThis._flutter,
      j: (x0,x1,x2) => x0.call(x1,x2),
      jB: (t, s) => t.set(s),
      jC: Function.prototype.call.bind(String.prototype.toLowerCase),
      jD: x0 => x0.disconnect(),
      jE: x0 => x0.offsetParent,
      jF: x0 => x0.hostElement,
      jG: (x0,x1) => x0.fetch(x1),
      jH: (x0,x1) => x0.getElementsByClassName(x1),
      jI: () => globalThis.window,
      jJ: x0 => x0.read(),
      k: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      kB: Function.prototype.call.bind(DataView.prototype.setFloat32),
      kC: Object.is,
      kD: x0 => new Intl.Locale(x0),
      kE: x0 => x0.offsetY,
      kF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      kG: x0 => x0.fontFallbackBaseUrl,
      kH: (x0,x1) => x0.dispatchEvent(x1),
      kI: (x0,x1) => { x0.src = x1 },
      kJ: x0 => x0.cancel(),
      l: x0 => new Array(x0),
      lB: Function.prototype.call.bind(DataView.prototype.getFloat32),
      lC: x0 => x0.vendor,
      lD: x0 => x0.region,
      lE: x0 => x0.offsetX,
      lF: x0 => ({runApp: x0}),
      lG: (handle) => clearInterval(handle),
      lH: (x0,x1) => x0.createEvent(x1),
      lI: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      lJ: x0 => x0.body,
      m: o => [o],
      mB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      mC: (x0,x1) => x0.createTextNode(x1),
      mD: x0 => x0.script,
      mE: (x0,x1) => x0[x1],
      mF: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      mG: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      mH: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      mI: (x0,x1,x2) => x0.addEventListener(x1,x2),
      mJ: (x0,x1) => x0.get(x1),
      n: (o0, o1) => [o0, o1],
      nB: Function.prototype.call.bind(DataView.prototype.getUint32),
      nC: (x0,x1) => { x0.id = x1 },
      nD: x0 => x0.language,
      nE: (o, p, r) => o.replace(p, () => r),
      nF: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      nG: () => Date.now(),
      nH: x0 => x0.readText(),
      nI: x0 => x0.data,
      nJ: x0 => x0.headers,
      o: (o0, o1, o2) => [o0, o1, o2],
      oB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      oC: (x0,x1) => { x0.nonce = x1 },
      oD: x0 => x0.languages,
      oE: (o, p, r) => o.replaceAll(p, () => r),
      oF: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      oG: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      oH: x0 => x0.clipboard,
      oI: x0 => x0.close(),
      oJ: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      p: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      pB: Function.prototype.call.bind(DataView.prototype.getInt32),
      pC: x0 => x0.nonce,
      pD: (x0,x1) => x0.observe(x1),
      pE: x0 => x0.deltaMode,
      pF: () => typeof dartUseDateNowForTicks !== "undefined",
      pG: x0 => x0.history,
      pH: (x0,x1) => x0.writeText(x1),
      pI: (o, p, v) => o[p] = v,
      pJ: () => globalThis.window._flutter_skwasmInstance,
      q: (x0,x1,x2) => { x0[x1] = x2 },
      qB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      qC: () => globalThis.window.flutterConfiguration,
      qD: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      qE: x0 => x0.deltaY,
      qF: () => Date.now(),
      qG: x0 => x0.search,
      qH: x0 => x0.unlock(),
      qI: x0 => x0.height,
      qJ: () => globalThis.window.flutterCanvasKit,
      r: (o, p) => o[p],
      rB: o => o instanceof Uint16Array,
      rC: (x0,x1) => x0.attachShadow(x1),
      rD: x0 => new ResizeObserver(x0),
      rE: x0 => x0.deltaX,
      rF: () => 1000 * performance.now(),
      rG: x0 => x0.location,
      rH: (x0,x1) => x0.lock(x1),
      rI: x0 => x0.width,
      rJ: (a, l) => a.length = l,
      s: () => globalThis,
      sB: Function.prototype.call.bind(DataView.prototype.getUint16),
      sC: (x0,x1) => x0.createElement(x1),
      sD: (x0,x1) => x0.getPropertyValue(x1),
      sE: x0 => x0.wheelDeltaY,
      sF: (x0,x1) => x0.requestAnimationFrame(x1),
      sG: x0 => x0.pathname,
      sH: x0 => x0.orientation,
      sI: (x0,x1,x2,x3,x4,x5) => x0.createImageBitmap(x1,x2,x3,x4,x5),
      sJ: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      t: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      tB: o => o instanceof Int16Array,
      tC: x0 => x0.scale,
      tD: x0 => globalThis.parseFloat(x0),
      tE: x0 => x0.wheelDeltaX,
      tF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      tG: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      tH: (x0,x1) => x0.querySelector(x1),
      tI: (x0,x1,x2) => x0.createImageBitmap(x1,x2),
      tJ: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9) => x0.drawImage(x1,x2,x3,x4,x5,x6,x7,x8,x9),
      u: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      uB: Function.prototype.call.bind(DataView.prototype.getInt16),
      uC: x0 => x0.visualViewport,
      uD: (x0,x1) => x0.getComputedStyle(x1),
      uE: x0 => x0.bottom,
      uF: x0 => x0.now(),
      uG: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      uH: (x0,x1) => { x0.title = x1 },
      uI: (x0,x1) => x0.createImageBitmap(x1),
      uJ: (x0,x1) => x0.getContext(x1),
      v: (x0,x1) => ({addView: x0,removeView: x1}),
      vB: o => o instanceof Uint8ClampedArray,
      vC: x0 => x0.devicePixelRatio,
      vD: x0 => x0.documentElement,
      vE: x0 => x0.right,
      vF: x0 => x0.performance,
      vG: o => Object.keys(o),
      vH: (x0,x1) => x0.vibrate(x1),
      vI: x0 => new Blob(x0),
      vJ: (x0,x1) => { x0.height = x1 },
      w: (l, r) => l === r,
      wB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint8Array) return 1;
        return 2;
      },
      wC: x0 => x0.height,
      wD: x0 => x0.computedStyleMap(),
      wE: x0 => x0.clientY,
      wF: x0 => new Uint8Array(x0),
      wG: x0 => x0.state,
      wH: x0 => x0.content,
      wI: x0 => x0.close(),
      wJ: (x0,x1) => { x0.width = x1 },
      x: x0 => x0.random(),
      xB: Function.prototype.call.bind(DataView.prototype.setInt32),
      xC: x0 => x0.width,
      xD: (x0,x1) => x0.get(x1),
      xE: x0 => x0.clientX,
      xF: (x0,x1,x2) => x0.slice(x1,x2),
      xG: x0 => x0.hash,
      xH: x0 => x0.document,
      xI: x0 => x0.naturalHeight,
      xJ: (x0,x1) => x0.transferFromImageBitmap(x1),
      y: () => globalThis.Math,
      yB: Function.prototype.call.bind(DataView.prototype.setUint32),
      yC: x0 => x0.screen,
      yD: (o, p) => p in o,
      yE: x0 => x0.changedTouches,
      yF: (x0,x1) => x0.decode(x1),
      yG: x0 => x0.state,
      yH: (x0,x1,x2) => x0.insertBefore(x1,x2),
      yI: x0 => x0.naturalWidth,
      yJ: x0 => x0.rasterEndMilliseconds,
      z: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      zB: Function.prototype.call.bind(DataView.prototype.setInt16),
      zC: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      zD: (x0,x1) => { x0.textContent = x1 },
      zE: x0 => x0.key,
      zF: (x0,x1) => x0.adoptText(x1),
      zG: (x0,x1) => x0.go(x1),
      zH: x0 => x0.id,
      zI: (x0,x1) => { x0.src = x1 },
      zJ: x0 => x0.rasterStartMilliseconds,

    };

    const baseImports = {
      _: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      WebAssembly: {
        JSTag: WebAssembly.JSTag,
      },
      "": new Proxy({}, { get(_, prop) { return prop; } }),

    };

    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
