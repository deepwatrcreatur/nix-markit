{ lib
, buildNpmPackage
, importNpmLock
, fetchFromGitHub
}:

buildNpmPackage {
  pname = "markit-ai";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "Michaelliv";
    repo = "markit";
    rev = "v0.5.3";
    hash = "sha256-7TDou6PJ04ZN0hmfOlXRUCLzIF5JNfUAGlyNVpcoUQg=";
  };

  # The upstream package.json includes @biomejs/biome which has platform-specific
  # optional deps. Use our committed package.json (biome excluded) and
  # package-lock.json (regenerated without biome).
  postPatch = ''
    cp ${./package.json} package.json
    cp ${./package-lock.json} package-lock.json
  '';

  # importNpmLock reads per-package integrity hashes from the committed
  # package-lock.json — no separate npmDepsHash to maintain.
  npmDeps = importNpmLock {
    npmRoot = ./.;
  };

  # importNpmLock sources use file:// store paths; they need their own
  # npmConfigHook (not the default fetchNpmDeps-based one).
  npmConfigHook = importNpmLock.npmConfigHook;

  meta = with lib; {
    description = "Convert anything to markdown: PDF, DOCX, PPTX, XLSX, HTML, EPUB, Jupyter, RSS, images, audio, URLs, and more";
    homepage = "https://github.com/Michaelliv/markit";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "markit";
  };
}
