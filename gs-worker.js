importScripts('gs.js'); // Import Ghostscript WebAssembly

Module({
    noInitialRun: true,
    print: (text) => {
        postMessage({ type: 'stdout', data: text });
    },
    printErr: (text) => {
        postMessage({ type: 'stderr', data: text });
    },
}).then((Module) => {
    postMessage({ type: 'ready' });

    onmessage = async (e) => {
        if (e.data.type === 'run') {
            try {
                const { args, fileContent, fileName } = e.data;

                // Mount input file
                Module.FS.writeFile('/input.pdf', new Uint8Array(fileContent));

                // Run Ghostscript with provided arguments
                Module.callMain(args);

                // Retrieve and send back the output file
                const outputFile = Module.FS.readFile('/output.pdf');
                const outputFileName = `compressed_${fileName}`;
                postMessage({ type: 'result', data: { fileContent: outputFile, fileName: outputFileName } });
            } catch (err) {
                postMessage({ type: 'error', data: err.toString() });
            }
        }
    };
});
