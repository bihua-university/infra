{
  infra = {
    hosts = {
      cosimo = {
        system = "x86_64-linux";
        directory = ./hosts.d/cosimo;
      };
      sheepro = {
        system = "x86_64-linux";
        directory = ./hosts.d/sheepro;
      };
    };
    share-module = ./share-modules;
  };
}
