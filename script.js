const worker = new Worker('gs-worker.js');
const outputElement = document.getElementById("output");
let loadedFiles = [];

worker.onmessage = (e) => {
    const { type, data } = e.data;

    if (type === 'ready') {
        console.log('Worker ready!');
    } else if (type === 'stdout') {
        console.log("GS>", data);
        outputElement.textContent += data + "\n";
        outputElement.scrollTop = outputElement.scrollHeight;
    } else if (type === 'stderr') {
        console.error("GS ERROR>", data);
        outputElement.textContent += "ERROR: " + data + "\n";
        outputElement.scrollTop = outputElement.scrollHeight;
    } else if (type === 'result') {
        console.log(`PDF compression complete for ${data.fileName}!`);

        // Retrieve the output file and trigger download
        const blob = new Blob([data.fileContent], { type: 'application/pdf' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = data.fileName;
        link.click();

        outputElement.textContent += `PDF compression complete for ${data.fileName}!\n`;
    } else if (type === 'error') {
        console.error('Error:', data);
        outputElement.textContent += "Error: " + data + "\n";
    }
};

document.getElementById("fileInput").addEventListener("change", async (event) => {
    const files = event.target.files;
    loadedFiles = [];

    for (let file of files) {
        const fileContent = await file.arrayBuffer();
        loadedFiles.push({ fileContent, fileName: file.name });
        console.log(`Loaded: ${file.name}`);
        outputElement.textContent += `Loaded: ${file.name}\n`;
    }
});

document.getElementById("startCompression").addEventListener("click", () => {
    if (loadedFiles.length > 0) {
        const args = document.getElementById("arguments").value.trim().split(/\s+/);

        for (let { fileContent, fileName } of loadedFiles) {
            worker.postMessage({ type: 'run', args, fileContent, fileName });
        }
    } else {
        outputElement.textContent += "No files loaded.\n";
    }
});

document.getElementById("clearOutput").addEventListener("click", () => {
    outputElement.textContent = "";
});