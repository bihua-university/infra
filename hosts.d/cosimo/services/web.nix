{
  pkgs,
  config,
  modules,
  lib,
  ...
}:

let
  enable = true;
  inherit (config.sops) secrets;

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

  host = "100.76.29.108";
  domain = "code.estin.space";
in
{
  imports = [ modules.services.oxicloud ];

  services.calibre-web = {
    inherit enable;
    package = calibre-web-minimal;
    openFirewall = true;
    listen = {
      ip = host;
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
      session.COOKIE_SECURE = true;
      server = {
        HTTP_ADDR = host;
        HTTP_PORT = 8085;
        PROTOCOL = "http";
        DOMAIN = domain;
        ROOT_URL = "https://${domain}";
        DISABLE_SSH = true;
        START_SSH_SERVER = true;
        SSH_LISTEN_PORT = 8086;
      };
      service = {
        ENABLE_REVERSE_PROXY_AUTHENTICATION = true;
        ENABLE_REVERSE_PROXY_EMAIL = true;
      };
      security.REVERSE_PROXY_TRUSTED_PROXIES = "127.0.0.0/8,::1/128,100.64.0.0/10";
      log.LEVEL = "Warn";
      service.DISABLE_REGISTRATION = false;
      "cron.update_checker".ENABLED = false;
    };
    dump = {
      enable = true;
      type = "tar.bz2";
    };
    database.type = "sqlite3";
  };

  sops.secrets.forgejo-runner-token = { };
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.local =
      let
        inherit (config.services.forgejo.settings.server) HTTP_ADDR HTTP_PORT;
      in
      {
        enable = true;
        name = config.networking.hostName;
        url = "http://${HTTP_ADDR}:${toString HTTP_PORT}";
        tokenFile = secrets.forgejo-runner-token.path;
        labels = [ "native:host" ];
        hostPackages = with pkgs; [
          bash
          fish
          nushell
          coreutils

          curl
          gawk
          wget
          gitMinimal
          gnused

          nodejs
          guile
          python3
        ];
      };
  };

  services.oxicloud = {
    enable = true;
    settings = {
      port = 8087;
      inherit host;
      baseUrl = "https://cloud.estin.space";
    };
  };
}
