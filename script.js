// --- UI Element References ---
const loadingContainer = document.getElementById("loading_container");
const loadingStatus = document.getElementById("loading_status");
const progressBarInner = document.getElementById("progress_bar_inner");
const emulatorContainer = document.getElementById("emulator_container");
const stateText = document.getElementById("state_text");

// --- Loading Process ---
(function() {
    // Wait for the DOM to be fully loaded before starting
    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", start);
    } else {
        start();
    }

    function start() {
        loadingStatus.textContent = "Initializing emulator...";

        const emulator = new window.V86Starter({
            wasm_path: "https://unpkg.com/v86/build/v86.wasm",
            memory_size: 512 * 1024 * 1024,
            vga_memory_size: 8 * 1024 * 1024,
            serial_container: document.getElementById("serial_container"),
            screen_container: document.getElementById("screen_container"),
            initial_state: {
                url: "https://v86.app/images/archlinux.json",
            },
            filesystem: {
                persistent: true,
            },
            autostart: true,
        });

        // --- Event Listeners for Loading and State ---

        emulator.add_listener("download-progress", function(e) {
            const total = e.total;
            const loaded = e.loaded;
            const percentage = Math.round((loaded / total) * 100);

            loadingStatus.textContent = `Downloading Linux image... (${(loaded / 1024 / 1024).toFixed(1)} / ${(total / 1024 / 1024).toFixed(1)} MB)`;
            progressBarInner.style.width = percentage + "%";
        });

        emulator.add_listener("emulator-loaded", function() {
            loadingStatus.textContent = "Image downloaded. Booting OS...";
            stateText.textContent = "Ready";
        });

        emulator.add_listener("boot-ok", function() {
            loadingContainer.style.display = "none";
            emulatorContainer.style.display = "flex";
        });

        emulator.add_listener("save-state-start", function() {
            stateText.textContent = "Saving...";
        });

        emulator.add_listener("save-state-end", function() {
            stateText.textContent = "Saved";
        });

        emulator.add_listener("restore-state-start", function() {
            loadingStatus.textContent = "Restoring state from browser DB...";
            stateText.textContent = "Restoring...";
        });

        emulator.add_final_listener("restore-state-end", function() {
            stateText.textContent = "Restored";
        });
    }
})();
