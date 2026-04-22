import WebSocket from "ws"

// Keep the live test runtime stable across Node versions and GitHub runners.
globalThis.WebSocket = WebSocket
