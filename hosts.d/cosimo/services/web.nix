{
  pkgs,
  ...
}:

let
  enable = true;

  # hilarious
  # https://github.com/janeczku/calibre-web/issues/2963
  calibre-web-minimal = pkgs.calibre-web.overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + ''
      providerDir=$(find $out -path "*/cps/metadata_provider" -type d | head -1)

      if [ -n "$providerDir" ]; then
        echo "Cleaning metadata providers in $providerDir"
        for f in "$providerDir"/*.py; do
          basename=$(basename "$f")
          if [ "$basename" != "__init__.py" ] && [ "$basename" != "douban.py" ]; then
            echo "  Removing: $basename"
            rm "$f"
          fi
        done
        ls -la "$providerDir"
      fi
    '';
  });

  domain = "code.estin.space";
in
{
  services.calibre-web = {
    inherit enable;
    package = calibre-web-minimal;
    openFirewall = true;
    listen = {
      ip = "100.76.29.108";
      port = 8083;
    };
    options = {
      calibreLibrary = "/srv/bib";
      enableBookConversion = true;
      enableBookUploading = true;
      enableKepubify = true;
    };
  };

  preservation.preserveAt."/persist" = {
    directories = [ "/srv/bib" ];
  };

  services.forgejo = {
    inherit enable;
    settings = {
      settings.COOKIE_SECURE = true;
      server = {
        HTTP_ADDR = "100.76.29.108";
        HTTP_PORT = 8085;
        PROTOCOL = "http";
        DOMAIN = domain;
        ROOT_URL = "https://${domain}";
      };
      service = {
        ENABLE_REVERSE_PROXY_AUTHENTICATION = true;
        ENABLE_REVERSE_PROXY_EMAIL = true;
      };
      security.REVERSE_PROXY_TRUSTED_PROXIES = "127.0.0.0/8,::1/128,100.64.0.0/10";
      log.LEVEL = "Debug";
      service.DISABLE_REGISTRATION = true;
    };
    dump = {
      enable = true;
      type = "tar.bz2";
    };
    database.type = "sqlite3";
  };

  # topology.self = {
  #   services.librechat = {
  #     name = "LibreChat";
  #     info = "chat.bhu.social";
  #     icon = pkgs.fetchurl {
  #       url = "https://raw.githubusercontent.com/danny-avila/LibreChat/35319c135459be9580cee97ef7d72e225526592a/client/public/assets/logo.svg";
  #       sha256 = "sha256-byLpRkFQIqT7SZ2dpI7qYf6tbmXrRJtT7HjZWw9uT3A=";
  #     };
  #   };
  # };
}
