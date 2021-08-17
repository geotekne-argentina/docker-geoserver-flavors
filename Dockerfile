FROM geotekne/gdal:2.1.4
LABEL maintainer="geotekne.argentina@gmail.com"

#
# GEOSERVER DEPENDENCIES
#
RUN apk --update --no-cache add ttf-dejavu openssl pkgconfig 

ENV GEOSERVER_VERSION 2.16.2
ENV GEOSERVER_HOME /opt/geoserver
ENV GEOSERVER_DATA_DIR /var/local/geoserver

ENV PATH $JAVA_HOME/bin:$PATH
ENV JAVA_OPTS "-server -Xms768m -Xmx1560m -XX:+UseParallelOldGC -XX:NewRatio=2" 

#
# GEOSERVER INSTALLATION
#
# Get Geoserver
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/geoserver-$GEOSERVER_VERSION-bin.zip -O ~/geoserver.zip && \
    unzip ~/geoserver.zip -d /opt && mv -v /opt/geoserver* /opt/geoserver && \
    rm ~/geoserver.zip && \
# Create data_dir and move Geoserver data_dir sample
    mkdir $GEOSERVER_DATA_DIR && mv /opt/geoserver/data_dir/* $GEOSERVER_DATA_DIR && rm -rf /opt/geoserver/data_dir && \
# Get OGR plugin
    wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-ogr-wfs-plugin.zip -O ~/geoserver-ogr-plugin.zip &&\
    unzip -o ~/geoserver-ogr-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-ogr-plugin.zip && \
# Get GDAL plugin
    wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-gdal-plugin.zip -O ~/geoserver-gdal-plugin.zip &&\
    unzip -o ~/geoserver-gdal-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-gdal-plugin.zip && \
# Get import plugin
    wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-importer-plugin.zip -O ~/geoserver-importer-plugin.zip &&\
    unzip -o ~/geoserver-importer-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-importer-plugin.zip && \
# Replace GDAL Java bindings
    rm -rf $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/imageio-ext-gdal-bindings-*.jar && \
    cp /usr/share/gdal.jar $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/gdal.jar && \
# Clustering plugin (manual url set)
    wget -c https://www.geotekne.com.ar/files/geoserver-$GEOSERVER_VERSION/geoserver-$GEOSERVER_VERSION-jms-cluster-plugin.zip -O ~/jms.zip &&\
    unzip -o ~/jms.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ &&\
    rm ~/jms.zip && \
#Cgastrel Plugins
    wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-printing-plugin.zip -O ~/geoserver-printing-plugin.zip &&\
    unzip ~/geoserver-printing-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-printing-plugin.zip && \
    wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-css-plugin.zip -O ~/geoserver-css-plugin.zip &&\
    unzip ~/geoserver-css-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-css-plugin.zip && \
    wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-querylayer-plugin.zip -O ~/geoserver-querylayer-plugin.zip &&\
    unzip ~/geoserver-querylayer-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-querylayer-plugin.zip && \
    wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-sldservice-plugin.zip -O ~/gs-sldservice-plugin.zip &&\
    unzip -o ~/gs-sldservice-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/  &&\
    rm ~/gs-sldservice-plugin.zip


# Configurations
COPY ./jetty/bin/startup.sh $GEOSERVER_HOME/bin/
RUN chmod 755 $GEOSERVER_HOME/bin/startup.sh

COPY ./jetty/start.ini $GEOSERVER_HOME/
COPY ./jetty/modules/rewrite.mod $GEOSERVER_HOME/modules/
COPY ./jetty/lib/jetty-rewrite-9.4.18.v20190429.jar $GEOSERVER_HOME/lib/
COPY ./jetty/etc/jetty-rewrite.xml $GEOSERVER_HOME/etc/

# Expose GeoServer's default port
EXPOSE 8080
CMD ["/opt/geoserver/bin/startup.sh"]
