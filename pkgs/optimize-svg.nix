{
  runCommandLocal,
  writeText,
  scour,
  svgo,
  src,
  ...
}:

runCommandLocal "optimized.svg"
  {
    buildInputs = [
      scour
      svgo
    ];
  }
  (
    let
      svgoConfig = writeText "svgo.config.js" ''
        module.exports = {
          plugins: [
            "preset-default",
            "removeTitle",
          ],
        };
      '';
    in
    ''
      scour \
        --enable-viewboxing \
        --strip-xml-prolog \
        --no-line-breaks \
        -i ${src} \
        -o temp.svg

      svgo \
        --config ${svgoConfig} \
        -i temp.svg \
        -o $out

      if [ ! -s $out ]; then
        echo "Error: Output file is empty!" >&2
        exit 1
      fi
    ''
  )
