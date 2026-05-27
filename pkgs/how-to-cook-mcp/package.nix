{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "how-to-cook-mcp";
  version = "0-unstable-2026-01-19";

  src = fetchFromGitHub {
    owner = "worryzyy";
    repo = "HowToCook-mcp";
    rev = "b444ae2d0ffa08520f76d1291d683ac1884abff3";
    hash = "sha256-DInHvIhLSjMCUVNBnJTAYC+xYslXyIHX7t1FgY+lVCk=";
  };

  npmDepsHash = "sha256-ycmM9lAYtq/YZcmkAXg+qoToCDxFv7XE5kQdyRpEdZo=";
  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  meta = {
    description = "基于Anduin2017 / HowToCook （程序员在家做饭指南）的mcp server";
    homepage = "https://github.com/worryzyy/HowToCook-mcp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jinser ];
    mainProgram = "howtocook-mcp";
    platforms = lib.platforms.all;
  };
})
