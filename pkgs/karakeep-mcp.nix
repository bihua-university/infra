{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs, # 24
  pnpm_9,
  pnpmConfigHook,
  fetchPnpmDeps,
  ...
}:

let
  pnpm = pnpm_9;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "karakeep-mcp";
  version = "0.31.0";

  src = fetchFromGitHub {
    owner = "karakeep-app";
    repo = "karakeep";
    rev = "mcp/v${finalAttrs.version}";
    hash = "sha256-++aNTkLOkwgkzRxg/WdrHfchXQwUUir0qqmb7WfdZJ0=";
  };

  pnpmWorkspaces = [
    "@karakeep/mcp"
    "@karakeep/sdk"
    "@karakeep/tsconfig"
  ];

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      ;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-+MbKG0h3cD0kZua0OkdQsUeTjAY4ysK41KXUSaOSKHA=";
  };

  buildPhase = ''
    runHook preBuild
    pnpm --filter=@karakeep/mcp build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp apps/mcp/dist/index.js $out/bin/karakeep-mcp

    patchShebangs $out/bin/*

    runHook postInstall
  '';

  meta = with lib; {
    description = "MCP package for Karakeep";
    homepage = "https://github.com/karakeep-app/karakeep/tree/main/apps/mcp";
    license = licenses.agpl3Only;
    mainPlatform = "karakeep-mcp";
    platforms = platforms.all;
  };
})
