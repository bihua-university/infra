{
  modules,
  ...
}:

{
  imports = with modules.snippets.cloud; [
    user
    ssh
    optimization
  ];
}
