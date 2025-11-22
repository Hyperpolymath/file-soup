# FSLint

**Cross-platform file system intelligence tool with a Notepad++-style plugin architecture**

FSLint provides contextual metadata about files through tiny, composable plugins that can be enabled/disabled individually. Get instant insights about git status, file age, duplicates, AI-generated content, secrets, and more.

[![License: Triple](https://img.shields.io/badge/license-MIT%20%7C%20Apache--2.0%20%7C%20Palimpsest-blue.svg)](LICENSE-MIT)
[![Rust](https://img.shields.io/badge/rust-1.70%2B-orange.svg)](https://www.rust-lang.org/)
[![RSR Compliant](https://img.shields.io/badge/RSR-Gold%20Tier-gold.svg)](docs/RSR_COMPLIANCE.md)
[![TPCF](https://img.shields.io/badge/TPCF-Perimeter%203%20Open-green.svg)](docs/TPCF.md)
[![RFC 9116](https://img.shields.io/badge/RFC%209116-security.txt-blue.svg)](.well-known/security.txt)

## 🚀 Features

- **Plugin Architecture**: Tiny, composable plugins inspired by Notepad++
- **8 Built-in Plugins**: Git status, file age, grouping, version detection, and more
- **Smart Caching**: Intelligent caching by (path, mtime, size) for fast re-scans
- **Query Engine**: Powerful filtering with `name:`, `ext:`, `newest:` syntax
- **Multiple Output Formats**: Table, JSON, or simple text
- **Offline-First**: Works completely air-gapped, no network calls
- **Cross-platform**: Works on Linux, macOS, and Windows
- **Performance Focused**: Configurable max-depth, .gitignore support

## 📦 Installation

### From Source

```bash
git clone https://github.com/Hyperpolymath/file-soup.git
cd file-soup
cargo build --release
```

The binary will be at `./target/release/fslint`

### Using Cargo

```bash
cargo install fslint
```

## 🎯 Quick Start

```bash
# Scan current directory
fslint scan

# Scan with JSON output
fslint scan --format json

# Query for specific files
fslint query "name:config ext:toml"

# Find newest version of a file
fslint query "name:report newest:true"

# List all plugins
fslint plugins

# Enable/disable plugins
fslint enable secret-scanner
fslint disable grouping
```

## 🔌 Built-in Plugins

| Plugin | Default | Description |
|--------|---------|-------------|
| **git-status** | ✅ | Shows git repo status and branch info |
| **file-age** | ✅ | Highlights recently modified files (< 7 days) |
| **grouping** | ✅ | Categorizes files (node_modules, media, etc.) |
| **version-detection** | ❌ | Finds versioned files (file_v1, file_final) |
| **ocr-status** | ❌ | Detects PDF text layers |
| **ai-detection** | ❌ | Identifies AI-generated images via EXIF |
| **duplicate-finder** | ❌ | Hash-based duplicate detection |
| **secret-scanner** | ❌ | Finds exposed API keys and secrets |

## 📖 Usage Examples

### Basic Scanning

```bash
# Scan current directory with table output
fslint scan

# Scan specific directory
fslint scan /path/to/project

# Use simple output format
fslint scan --format simple

# Export to JSON
fslint scan --format json > results.json
```

### Query Examples

```bash
# Find all TypeScript files
fslint query "ext:ts"

# Find modified files
fslint query "git-status:Modified"

# Find recent large files
fslint query "size_gt:1048576 tag:age"

# Find AI-generated images
fslint enable ai-detection
fslint query "tag:ai"

# Find secrets in code
fslint enable secret-scanner
fslint scan --format table
```

### Plugin Management

```bash
# List all plugins and their status
fslint plugins

# Enable a plugin
fslint enable version-detection

# Disable a plugin
fslint disable grouping

# View current configuration
fslint config
```

## ⚙️ Configuration

FSLint stores configuration at `~/.config/fslint/config.toml`

```toml
enabled_plugins = ["git-status", "file-age", "grouping"]

[scanner]
max_depth = 10
include_hidden = false
follow_symlinks = false
respect_gitignore = true

[plugin_config.file-age]
threshold_days = "7"

[plugin_config.duplicate-finder]
min_size = "1024"

[plugin_config.secret-scanner]
max_file_size = "1048576"
```

## 🏗️ Architecture

```
file-soup/
├── crates/
│   ├── fslint-plugin-api/   # Plugin trait definitions
│   ├── fslint-plugin-sdk/   # Helper utilities
│   ├── fslint-core/         # Scanner, loader, config
│   └── fslint-cli/          # CLI interface
└── plugins/
    ├── git-status/
    ├── file-age/
    ├── grouping/
    └── ... (8 total)
```

### Plugin Development

Create a new plugin in 3 steps:

1. **Create plugin directory**:
```bash
mkdir plugins/my-plugin
cd plugins/my-plugin
```

2. **Add Cargo.toml**:
```toml
[package]
name = "fslint-plugin-my-plugin"
version = "0.1.0"

[dependencies]
fslint-plugin-api = { path = "../../crates/fslint-plugin-api" }
fslint-plugin-sdk = { path = "../../crates/fslint-plugin-sdk" }
```

3. **Implement Plugin trait** in `src/lib.rs`:
```rust
use fslint_plugin_api::{Plugin, PluginContext, PluginResult, PluginMetadata};

pub struct MyPlugin;

impl Plugin for MyPlugin {
    fn metadata() -> PluginMetadata {
        PluginMetadata {
            name: "my-plugin".into(),
            version: "0.1.0".into(),
            description: "My awesome plugin".into(),
            author: Some("Your Name".into()),
            enabled_by_default: false,
        }
    }

    fn check(&self, context: &PluginContext) -> Result<PluginResult, PluginError> {
        // Your plugin logic here
        Ok(PluginResult::active("my-plugin", "Found something!"))
    }
}
```

4. **Register plugin** in `crates/fslint-cli/src/commands.rs`

See existing plugins for complete examples.

## 🎨 Output Formats

### Table Format (Default)
```
File                                               Git             Age             Group                Other
------------------------------------------------------------------------------------------------------------------------
src/main.rs                                        Modified        Today           -                    -
package.json                                       Clean           This week       -                    -
node_modules/react/index.js                        -               -               Node Dependencies    -
```

### JSON Format
```json
[
  {
    "path": "/project/src/main.rs",
    "size": 1234,
    "results": [
      {
        "plugin_name": "git-status",
        "status": "Alert",
        "message": "Modified",
        "color": "yellow"
      }
    ]
  }
]
```

### Simple Format
```
src/main.rs [Modified, Today]
package.json [Clean, This week]
node_modules/react/index.js [Node Dependencies]
```

## 🔍 Query Language

FSLint supports a powerful query syntax:

| Filter | Example | Description |
|--------|---------|-------------|
| `name:` | `name:config` | Match filename |
| `ext:` | `ext:rs` | Match extension |
| `newest:true` | `newest:true` | Return newest file only |
| `tag:` | `tag:media` | Match plugin tag |
| `size_gt:` | `size_gt:1024` | Files larger than size |
| `size_lt:` | `size_lt:1048576` | Files smaller than size |
| `<plugin>:` | `git-status:Modified` | Match plugin result |

Combine filters with spaces:
```bash
fslint query "name:report ext:pdf newest:true"
```

## 🚦 Performance

- **Smart Caching**: Results cached by (path, mtime, size) - unchanged files use cache
- **Max Depth**: Default limit of 10 levels prevents deep recursion
- **.gitignore Support**: Respects .gitignore by default
- **Lazy Plugin Execution**: Only enabled plugins run
- **Parallel Scanning**: (Planned for v0.2.0)

Benchmark on a typical project:
```
Initial scan:    ~500ms (1000 files)
Cached re-scan:  ~50ms  (90% cache hit rate)
```

## 🛣️ Roadmap

### v0.2.0 (Next)
- [ ] WASM plugin runtime support
- [ ] Parallel file scanning
- [ ] Plugin configuration UI
- [ ] macOS bundle collapsing (`.app` as single entity)

### v0.3.0 (Future)
- [ ] Shell extension integration (Explorer/Finder/Nautilus)
- [ ] Shadow navigation for symlinks
- [ ] Virtual filesystem across disks/cloud
- [ ] Email attachment integration
- [ ] Focus mode filters

### Planned Plugins
- [ ] Malware scanner
- [ ] License detector
- [ ] Dependency analyzer
- [ ] Code complexity metrics
- [ ] Image metadata extractor

## 🤝 Contributing

Contributions welcome! Areas of interest:

1. **New Plugins**: Implement new file intelligence features
2. **Performance**: Optimize scanning and caching
3. **Platform Support**: Test and improve Windows/macOS support
4. **Documentation**: Improve docs and examples
5. **Testing**: Add integration tests

## 📄 License

Licensed under either of:

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE))
- MIT license ([LICENSE-MIT](LICENSE-MIT))

at your option.

## 🙏 Acknowledgments

- Inspired by the plugin architecture of Notepad++
- Built with Rust and love for developer tools
- Thanks to the Rust community for excellent crates

## 🔗 Links

- [GitHub Repository](https://github.com/Hyperpolymath/file-soup)
- [Issue Tracker](https://github.com/Hyperpolymath/file-soup/issues)
- [Crates.io](https://crates.io/crates/fslint) (Coming soon)

---

**Made with ❤️ by the FSLint team**
