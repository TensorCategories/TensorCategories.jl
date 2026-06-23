# sudo apt install imagemagick librsvg2-bin
rsvg-convert -w 1000 -h 1000 -a logo-notext.svg -o /tmp/logo-render.png
magick /tmp/logo-render.png \
  -resize 500x500 \
  -gravity center \
  -background none \
  -extent 500x500 \
  github-org-logo.png
