{ lib
, buildNpmPackage
, importNpmLock
, fetchFromGitHub
, stdenvNoCC
, jq
}:

let
  rawSrc = fetchFromGitHub {
    owner = "Michaelliv";
    repo = "markit";
    rev = "v0.1.3";
    hash = "sha256-sC0DJnRv5Uh+4XoIYkSCeiTxtczhwcYrI1UIXA1wr3Y=";
  };

  # The upstream package.json includes @biomejs/biome which has platform-specific
  # optional deps. Use our committed package.json (biome excluded) and
  # package-lock.json (regenerated without biome).
  patchedSrc = stdenvNoCC.mkDerivation {
    name = "markit-src-patched";
    src = rawSrc;
    nativeBuildInputs = [ jq ];
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      cp ${./package.json} package.json
      cp ${./package-lock.json} package-lock.json
      cp -r . $out
    '';
  };
in

buildNpmPackage {
  pname = "markit-ai";
  version = "0.1.3";

  src = patchedSrc;

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
