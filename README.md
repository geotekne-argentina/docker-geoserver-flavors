# docker-geoserver-flavors
Various Geoserver configurations, dockerized.

Simplemente, diferentes dockerizaciones de Geoserver según el tipo de configuración requerida (basado en extensiones).

Basamos la selección de nombres de los "sabores" en la siguiente imagen de referencia.

 <img src="./docs/images/flavors.jpg" alt="flavors" width="50%" />



Adicionalmente, en cada imagen docker generada, tendremos 2 indices principales del versionado:

- Sistema Operativo de base. Ejemplos:  Debian Buster, Alpine, etc.
- Versión de Geoserver incluida. Ejemplo: 2.16.2

Un ejemplo de imagen que se puede encontrar en [dockerhub](https://hub.docker.com/repository/docker/geotekne/geoserver) es: 

- **lime-buster-2.16.2**, la cual hace referencia a la configuración seteada en sección a continuación, con base a Debian Buster como SO, y a la release 2.16.2 de Geoserver.



## Tabla de Sabores/Configuraciones

| Flavor | Configuration                                                | Notes                                                        |
| ------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ginger | **Alpine**: Alpine 3.11, OpenJDK 15, GDAL 2.1.4, Jetty 9.4.18, plugins: OGR, GDAL, import, JMS, CSS, printing, querylayer, sldservice | Una versión de uso general de Geoserver que provee un conjunto de plugins preinstalados razonable (ni excesivo ni demasiado acotado) <br/>27-Sep-2021: Se incluye overwrite de sqlite-jdbc - a version 3.34.0 - para dar soporte a Gpkg/Alpine desde version Geoserver 2.16.2. |
| lime   | **Buster**: Debian Buster, OpenJDK 11, Tomcat 9.0.20, plugins: CSS, Pregeneralized Features. Incluye fonts fonts-noto, fonts-dejavu, unifont, fonts-hanazono ( basado en docker de [Kartoza/Geoserver](https://hub.docker.com/r/kartoza/geoserver) - base tomcat:jdk11-openjdk-slim-buster) <br/>**Alpine**: Alpine 3.11, OpenJDK 15, Jetty 9.4.18, plugins: CSS, Pregeneralized Features. Incluye fonts fonts-noto, fonts-dejavu, unifont | Versión de Geoserver **útil para uso en caso de implementar un server OSM propio** (basado en esta [referencia](https://github.com/geosolutions-it/osm-styles) de implementación).<br/>Observación: Inicialmente, no se creó la versión utilizando SO Alpine de base ya que se detectaron problemas de compatibilidad con drivers SQLite necesarios para lectura de archivos tipo gpkg para version Geoserver 2.16.2 (basicamente sqlite-jdbc no soportaba Alpine hasta la release [3.31.1](https://github.com/xerial/sqlite-jdbc)).<br/>27-Sep-2021: Se crea version Alpine, que incluye overwrite de sqlite-jdbc - a version 3.34.0 - para dar soporte a Gpkg desde version Geoserver 2.16.2. |
| pear   | **Alpine**: Alpine 3.11, OpenJDK 15, Jetty 9.4.18, plugins: WPS, MBTiles plugin | Versión enfocada en uso de MBTiles/GPKGs como stores. <br/>27-Sep-2021: Se incluye overwrite de sqlite-jdbc - a version 3.34.0 - para dar soporte a Gpkg/Alpine desde version Geoserver 2.16.2. |



