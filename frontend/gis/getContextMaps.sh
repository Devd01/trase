#!/usr/bin/env bash

echo -e '// this file is generated by gis/getContextMaps.sh\nexport const contextLayersCarto = ' `./gis/cartodb/getContextMaps.js` ';' > scripts/actions/map/context_layers_carto.js
