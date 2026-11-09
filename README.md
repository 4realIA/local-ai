# Running AI locally on a Mac

How I run open AI models on my own Mac for chat, research and video, with web access only when I approve it, and how I check that the data stays put. The background and reasoning are on my site: [4ia.info/local-ai.html](https://4ia.info/local-ai.html).

Everything here runs on Apple Silicon. It needs no account, subscription or API key.

## What's in this repo

| File | What it is |
|---|---|
| `mcp.json.example` | LM Studio configuration for the two web tools (search and page fetch) |
| `check-connections.sh` | Lists the open network connections of the model app, so you can see whether anything leaves the machine |

## 1. Chat: LM Studio + an open model

1. Install [LM Studio](https://lmstudio.ai).
2. In its model search, download a Qwen model in **MLX** format. MLX models run fastest on Apple Silicon. Pick a size that leaves room for your other apps: as a rough guide, a model file around half of your Mac's memory or less.
3. Load it and chat. With no tools enabled, nothing you type leaves the machine.

## 2. Optional web access: two MCP tools

A model can't reach the internet on its own. These two open-source MCP servers give it a search tool and a page-fetch tool, and LM Studio asks before each call.

Install them with [uv](https://docs.astral.sh/uv/) ([Homebrew](https://brew.sh) shown):

```bash
brew install uv
uv tool install mcp-server-fetch
uv tool install duckduckgo-mcp-server
ls ~/.local/bin        # both should be listed
```

Then add them to LM Studio's `mcp.json` (in recent versions: the Program tab, then Install → Edit mcp.json; menus can move between versions). Copy `mcp.json.example` and replace `YOUR_USERNAME` with your Mac username (`whoami` prints it).

Why full paths: apps started from the Dock often don't see Homebrew's folders on their `PATH`, so a bare `uvx …` command can fail without an error. Full paths to the installed tools avoid that.

**Test it.** Start a new chat with the tools enabled and ask:

> Fetch https://example.com and tell me the exact page title and first sentence.

You should get an approval prompt before the answer. **If no prompt appears, the model answered from memory.** Local models will invent plausible news and URLs, so the prompt is the proof, not the answer.

What these tools send: search terms go to DuckDuckGo, and fetched pages see a request from your IP address. Nothing else does.

## 3. Check what connects out

```bash
chmod +x check-connections.sh
./check-connections.sh                  # LM Studio and its helpers
./check-connections.sh "mlx_video"      # any other process, by name
```

Run it while a model is answering with no tools in use. The list should be empty, or show only `127.0.0.1` entries (LM Studio's local server). Anything `ESTABLISHED` to another address is leaving the machine and worth looking up.

The other test needs no script: once models are downloaded, turn Wi-Fi off and run the same tasks.

**Expected connections:** model downloads (Hugging Face), app updates (the app's maker), and searches and fetches you approved (DuckDuckGo and the pages themselves).

## Video

The family video projects use the same principle with different tools, all local: Draw Things and Qwen Image Edit (via [mflux](https://github.com/filipstrand/mflux)) for pictures, Kokoro (via [mlx-audio](https://github.com/Blaizzy/mlx-audio)) for voices, and LTX-Video (via [mlx-video](https://github.com/Blaizzy/mlx-video)) for animation. That pipeline lives in its own project; the site page describes it.

## License

MIT. See `LICENSE`.
