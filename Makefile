# Makefile for FSLint

.PHONY: all build test bench lint fix clean docs run check ci install help

all: build

build:
	@echo "Building all crates..."
	@cargo build --workspace

build-release:
	@echo "Building release..."
	@cargo build --release --workspace

test:
	@echo "Running tests..."
	@cargo test --workspace

bench:
	@echo "Running benchmarks..."
	@cargo bench

lint:
	@echo "Running linters..."
	@cargo fmt --all -- --check
	@cargo clippy --workspace -- -D warnings

fix:
	@echo "Auto-fixing issues..."
	@cargo fmt --all
	@cargo clippy --workspace --fix --allow-dirty --allow-staged

clean:
	@echo "Cleaning build artifacts..."
	@cargo clean

docs:
	@echo "Generating documentation..."
	@cargo doc --workspace --no-deps --open

run:
	@cargo run --release -- scan .

check:
	@echo "Quick check..."
	@cargo check --workspace

ci: lint test build-release
	@echo "All CI checks passed!"

install:
	@echo "Installing FSLint..."
	@cargo install --path crates/fslint-cli

help:
	@echo "FSLint Development Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  build         - Build all crates (debug)"
	@echo "  build-release - Build release binary"
	@echo "  test          - Run all tests"
	@echo "  bench         - Run benchmarks"
	@echo "  lint          - Run clippy and format check"
	@echo "  fix           - Auto-fix formatting and clippy issues"
	@echo "  clean         - Clean build artifacts"
	@echo "  docs          - Generate and open documentation"
	@echo "  run           - Run FSLint CLI (scan current directory)"
	@echo "  check         - Quick check (faster than build)"
	@echo "  ci            - Run all CI checks"
	@echo "  install       - Install FSLint binary"
	@echo "  help          - Show this help"
