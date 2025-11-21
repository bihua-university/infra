{
  modules,
  ...
}:

{
  imports = builtins.attrValues modules.snippets.cloud;
}
