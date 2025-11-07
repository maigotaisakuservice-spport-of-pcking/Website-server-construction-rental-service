// Dynamically load the v86 library from a CDN
const v86Script = document.createElement('script');
v86Script.src = 'https://unpkg.com/v86/build/libv86.js';
document.head.appendChild(v86Script);

v86Script.onload = function() {
    console.log("v86 library loaded.");
    const loadingMessage = document.querySelector('p');

    // Configuration for a lightweight, yet functional, Arch Linux
    const emulator = new window.V86Starter({
        wasm_path: "https://unpkg.com/v86/build/v86.wasm",
        memory_size: 512 * 1024 * 1024, // 512 MB for a better experience
        vga_memory_size: 8 * 1024 * 1024,

        serial_container: document.getElementById("serial_container"),
        screen_container: document.getElementById("screen_container"),

        // Use a more capable Arch Linux image
        // The state is downloaded from a URL if not present in IndexedDB
        initial_state: {
            url: "https://v86.app/images/archlinux.json",
        },
        // Enable persistence to IndexedDB
        filesystem: {
            persistent: true,
        },

        autostart: true,
    });

    // --- State Persistence UI ---
    const stateText = document.getElementById("state_text");

    emulator.add_listener("emulator-loaded", function() {
        stateText.textContent = "Ready";
    });

    emulator.add_listener("save-state-start", function() {
        stateText.textContent = "Saving...";
    });

    emulator.add_listener("save-state-end", function() {
        stateText.textContent = "Saved";
    });

    emulator.add_listener("restore-state-end", function() {
        stateText.textContent = "Restored";
    });

    // Update the UI message
    loadingMessage.textContent = "Arch Linux is booting. Interact with the terminal below.";
};
