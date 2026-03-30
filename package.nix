{ lib
, buildNpmPackage
, fetchFromGitHub
, stdenvNoCC
, nodejs
, cacert
, jq
}:

let
  rawSrc = fetchFromGitHub {
    owner = "Michaelliv";
    repo = "markit";
    rev = "v0.1.3";
    hash = "sha256-sC0DJnRv5Uh+4XoIYkSCeiTxtczhwcYrI1UIXA1wr3Y=";
  };

  # The upstream package-lock.json is broken: it's missing `resolved` and `integrity`
  # fields for ~30 packages. Generate a fresh one via a fixed-output derivation
  # (FODs have network access). @biomejs/biome is removed since it's a linter
  # with platform-specific optional deps that aren't in the upstream lock file.
  freshLockFile = stdenvNoCC.mkDerivation {
    name = "markit-package-lock.json";

    outputHashMode = "flat";
    outputHashAlgo = "sha256";
    outputHash = "sha256-vrkluGNkZuutqZ/Z+SFjfrpYgLZsLJ1Ck/BA9KdCEW4=";

    nativeBuildInputs = [ nodejs jq cacert ];

    buildCommand = ''
      export NODE_EXTRA_CA_CERTS="${cacert}/etc/ssl/certs/ca-bundle.crt"
      cp -r ${rawSrc}/. work
      chmod -R u+w work
      cd work
      jq 'del(.devDependencies["@biomejs/biome"])' package.json > tmp.json
      mv tmp.json package.json
      rm -f package-lock.json
      HOME=$(mktemp -d) npm install --package-lock-only --ignore-scripts
      cp package-lock.json $out
    '';
  };

  patchedSrc = stdenvNoCC.mkDerivation {
    name = "markit-src-patched";
    src = rawSrc;
    nativeBuildInputs = [ jq ];
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      jq 'del(.devDependencies["@biomejs/biome"])' package.json > tmp.json
      mv tmp.json package.json
      cp ${freshLockFile} package-lock.json
      cp -r . $out
    '';
  };
in

buildNpmPackage {
  pname = "markit-ai";
  version = "0.1.3";

  src = patchedSrc;

  npmDepsHash = "sha256-f8bz65rcwimwjo28/nyoDfl7hfRpVMJfi13d1c1fEZ0=";

  meta = with lib; {
    description = "Convert anything to markdown: PDF, DOCX, PPTX, XLSX, HTML, EPUB, Jupyter, RSS, images, audio, URLs, and more";
    homepage = "https://github.com/Michaelliv/markit";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "markit";
  };
}
