default:
    just -h

stylua:
    stylua ./src

serve:
    rojo serve

sourcemap:
    rojo sourcemap --include-non-scripts -o ./sourcemap.json