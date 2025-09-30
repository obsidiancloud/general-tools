# Configuration Examples

This document provides common configuration examples for different use cases.

## Development Environment

Prioritize IDE, build tools, and development servers:

```bash
# Edit ~/.local/bin/priority-manager.sh

CRITICAL_APPS=("code" "vscode" "idea" "pycharm" "webstorm" "docker" "node" "npm" "yarn")
DEPRIORITIZE_APPS=("chrome" "firefox" "slack" "spotify" "discord")
```

## Trading Platform

Prioritize trading software and market data applications:

```bash
CRITICAL_APPS=("tradingview" "metatrader" "thinkorswim" "ninjatrader" "ib-gateway")
DEPRIORITIZE_APPS=("chrome" "firefox" "thunderbird" "telegram")
```

## Content Creation

Prioritize video editing, 3D rendering, and creative applications:

```bash
CRITICAL_APPS=("davinci-resolve" "blender" "obs" "kdenlive" "gimp" "inkscape")
DEPRIORITIZE_APPS=("chrome" "firefox" "discord" "spotify")
```

## Gaming

Prioritize game client and voice chat:

```bash
CRITICAL_APPS=("steam" "lutris" "discord" "teamspeak")
DEPRIORITIZE_APPS=("chrome" "firefox" "transmission" "deluge")
```

## Server Management

Prioritize SSH, monitoring tools, and terminal applications:

```bash
CRITICAL_APPS=("ssh" "tmux" "htop" "kubectl" "terraform" "ansible")
DEPRIORITIZE_APPS=("chrome" "firefox" "slack")
```

## Data Science / ML

Prioritize Jupyter, Python, and data processing tools:

```bash
CRITICAL_APPS=("jupyter" "python" "rstudio" "spyder" "docker")
DEPRIORITIZE_APPS=("chrome" "firefox" "slack" "spotify")
```

## Audio Production

Prioritize DAW and audio processing applications:

```bash
CRITICAL_APPS=("ardour" "reaper" "bitwig" "jack" "pulseaudio")
DEPRIORITIZE_APPS=("chrome" "firefox" "telegram")
```

## Tips

1. **Process Names**: Use `ps aux | grep app-name` to find the correct process name
2. **Multiple Instances**: The script handles multiple instances of the same application
3. **Child Processes**: Child processes are automatically prioritized
4. **Restart Required**: After editing, restart the service: `systemctl --user restart priority-manager`
