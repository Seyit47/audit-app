# Directions (GraphHopper)

The agent's map shows the way to a chosen shop along the roads. The phone asks the API
(`GET /v1/directions?fromLat=&fromLng=&toLat=&toLng=`), and the API asks [GraphHopper](https://www.graphhopper.com/open-source/)
on the same machine (`ROUTING_URL`, default `http://127.0.0.1:8989`). Without it the app draws a straight line to the shop.

## Run it

Java 17 or newer, `graphhopper-web-10.2.jar` (Maven Central) and Geofabrik's Turkmenistan extract next to `config.yml`:

```sh
curl -LO https://repo1.maven.org/maven2/com/graphhopper/graphhopper-web/10.2/graphhopper-web-10.2.jar
curl -L -o turkmenistan.osm.pbf https://download.geofabrik.de/asia/turkmenistan-latest.osm.pbf
java -Xmx1g -jar graphhopper-web-10.2.jar server config.yml
```

The first start builds `graph-cache/` (about a minute); later starts load it. Check it:

```sh
curl 'http://127.0.0.1:8989/route?point=37.95,58.38&point=37.93,58.40&profile=car&points_encoded=false&instructions=false'
```

On the Windows server, `install.ps1` runs it as the `audit-routing` service with the bundled Java (`routing\jre`).

To refresh the roads: replace `turkmenistan.osm.pbf`, delete `graph-cache/`, restart.

Road data: © OpenStreetMap contributors (ODbL).
