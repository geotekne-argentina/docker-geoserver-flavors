# docker-geoserver-flavors
Various Geoserver configurations, dockerized.

Simplemente, diferentes dockerizaciones de Geoserver según el tipo de configuración requerida (basado en extensiones).

Basamos la selección de nombres de los "sabores" en la siguiente imagen de referencia.

 <img src="./docs/images/flavors.jpg" alt="flavors" width="50%" />



El número de version de la imagen docker, indica la version de Geoserver incluida. 



## Tabla de Sabores/Configuraciones

| Flavor | Configuration                                                | Notes                                                        |
| ------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ginger | Alpine 3.11, OpenJDK 15, GDAL 2.1.4, Jetty 9.4.18, plugins: OGR, GDAL, import, JMS, CSS, printing, querylayer, sldservice | Una versión de uso general de Geoserver que provee un conjunto de plugins preinstalados razonable (ni excesivo ni demasiado acotado) |
| lime   | Debian Buster, OpenJDK 11, Tomcat 9.0.20, plugins: CSS, Pregeneralized Features. Incluye fonts fonts-noto, fonts-dejavu, unifont fonts-hanazono ( basado en docker de [Kartoza/Geoserver](https://hub.docker.com/r/kartoza/geoserver) (base tomcat:jdk11-openjdk-slim-buster) | Versión de Geoserver **útil para uso en caso de implementar un server OSM propio** (basado en esta [referencia](https://github.com/geosolutions-it/osm-styles) de implementación). Observación: No se creó la versión utilizando SO Alpine de base ya que se detectaron problemas de compatibilidad con drivers SQLite necesarios para lectura de archivos tipo gpkg. |



