# nix-markit

Nix flake for [markit](https://github.com/Michaelliv/markit) - a universal document-to-markdown converter.

## Description

markit converts various document formats to markdown, including:
- PDF
- DOCX
- PPTX
- XLSX
- HTML
- EPUB
- Jupyter notebooks
- RSS feeds
- Images (with OCR)
- Audio (with transcription)
- URLs

## Usage

### As a flake

```bash
# Run directly
nix run github:deepwatrcreatur/nix-markit# -- --help

# Or install globally
nix profile install github:deepwatrcreatur/nix-markit#
```

### In your NixOS configuration

```nix
{
  inputs.nix-markit.url = "github:deepwatrcreatur/nix-markit";

  nixpkgs.overlays = [
    inputs.nix-markit.overlays.default
  ];

  environment.systemPackages = [
    pkgs.markit
  ];
}
```

### As a dependency in another flake

```nix
{
  inputs.nix-markit.url = "github:deepwatrcreatur/nix-markit";

  outputs = { self, nixpkgs, nix-markit }: {
    packages = forAllSystems (system: {
      myPackage = myPackage.overrideAttrs (prev: {
        nativeBuildInputs = prev.nativeBuildInputs or [] ++ [
          nix-markit.packages.${system}.markit
        ];
      });
    });
  };
}
```

## Example

```bash
# Convert a PDF to markdown
markit document.pdf -o document.md

# Convert URL to markdown
markit https://example.com -o webpage.md

# Convert image with OCR
markit screenshot.png -o extracted.md
```

## License

MIT - see [upstream repository](https://github.com/Michaelliv/markit) for details.
