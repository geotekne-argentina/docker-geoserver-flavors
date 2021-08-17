#!/bin/sh
# -----------------------------------------------------------------------------
# Start Script for GEOSERVER
#
# $Id$
# -----------------------------------------------------------------------------

# Guard against misconfigured JAVA_HOME
if [ ! -z "$JAVA_HOME" -a ! -x "$JAVA_HOME"/bin/java ]; then
  echo "The JAVA_HOME environment variable is set but JAVA_HOME/bin/java"
  echo "is missing or not executable:"
  echo "    JAVA_HOME=$JAVA_HOME"
  echo "Please either set JAVA_HOME so that the Java runtime is JAVA_HOME/bin/java"
  echo "or unset JAVA_HOME to use the Java runtime on the PATH."
  exit 1
fi

# Find java from JAVA_HOME or PATH
if [ ! -z "$JAVA_HOME" ]; then
  _RUNJAVA="$JAVA_HOME"/bin/java
elif [ ! -z "$(which java)" ]; then
  _RUNJAVA=java
else
  echo "A Java runtime (java) was not found in JAVA_HOME/bin or on the PATH."
  echo "Please either set the JAVA_HOME environment variable so that the Java runtime"
  echo "is JAVA_HOME/bin/java or add the Java runtime to the PATH."
  exit 1
fi

if [ -z $GEOSERVER_HOME ]; then
  #If GEOSERVER_HOME not set then guess a few locations before giving
  # up and demanding user set it.
  if [ -r start.jar ]; then
     echo "GEOSERVER_HOME environment variable not found, using current "
     echo "directory.  If not set then running this script from other "
     echo "directories will not work in the future."
     export GEOSERVER_HOME=`pwd`
  else 
    if [ -r ../start.jar ]; then
      echo "GEOSERVER_HOME environment variable not found, using current "
      echo "location.  If not set then running this script from other "
      echo "directories will not work in the future."
      export GEOSERVER_HOME=`pwd`/..
    fi
  fi 

  if [ -z "$GEOSERVER_HOME" ]; then
    echo "The GEOSERVER_HOME environment variable is not defined"
    echo "This environment variable is needed to run this program"
    echo "Please set it to the directory where geoserver was installed"
    exit 1
  fi

fi

if [ ! -r "$GEOSERVER_HOME"/bin/startup.sh ]; then
  echo "The GEOSERVER_HOME environment variable is not defined correctly"
  echo "This environment variable is needed to run this program"
  exit 1
fi

#Find the configuration directory: GEOSERVER_DATA_DIR
if [ -z $GEOSERVER_DATA_DIR ]; then
    if [ -r "$GEOSERVER_HOME"/data_dir ]; then
        export GEOSERVER_DATA_DIR="$GEOSERVER_HOME"/data_dir
    else
        echo "No GEOSERVER_DATA_DIR found, using application defaults"
	      GEOSERVER_DATA_DIR=""
    fi
fi

cd "$GEOSERVER_HOME"

if [ -z $MARLIN_JAR]; then
    export MARLIN_JAR=`find \`pwd\`/webapps -name "marlin*.jar" | head -1`
fi
export MARLIN_ENABLER="-Xbootclasspath/a:$MARLIN_JAR -Dsun.java2d.renderer=org.marlin.pisces.MarlinRenderingEngine"

# Identify Geoserver instance
export GEOSERVER_NODE_OPTS=id:docker-$HOSTNAME

# echo "Setting cluster dir ..."
export CLUSTER_CONFIG_DIR="$GEOSERVER_DATA_DIR/cluster/$(hostname -s)"

# echo "Cleaning old cluster settings ..."
rm -vf $CLUSTER_CONFIG_DIR/*

# echo "Creating cluster.properties file ..."
mkdir -pv ${CLUSTER_CONFIG_DIR}
echo "#
#$(date)
toggleSlave=true
connection=enabled
topicName=VirtualTopic.>
brokerURL=
xbeanURL=./broker.xml
durable=false
toggleMaster=true
embeddedBroker=enabled
CLUSTER_CONFIG_DIR=${CLUSTER_CONFIG_DIR}
embeddedBrokerProperties=embedded-broker.properties
connection.retry=3
readOnly=disabled
instanceName="$(hostname -s)-$(openssl rand -hex 6)"
group=geoserver-cluster
connection.maxwait=10000" > ${CLUSTER_CONFIG_DIR}/cluster.properties

# echo "Setting broker ip ..."
# Here the cluster check
ip -f inet -o addr show ethwe0
if [ $? -eq 0 ]
then
  echo "Weave Network detected"
  export BROKERIP=$(ip -f inet -o addr show ethwe0 | awk '{print $4}' | cut -d/ -f1)
else
  echo "Weave Network does not exist - Set to local"
  export BROKERIP=0.0.0.0
fi

echo "GEOSERVER DATA DIR is $GEOSERVER_DATA_DIR"
#added headless to true by default, if this messes anyone up let the list
#know and we can change it back, but it seems like it won't hurt -ch
exec "$_RUNJAVA" $JAVA_OPTS $MARLIN_ENABLER -DGEOSERVER_DATA_DIR="$GEOSERVER_DATA_DIR" -Dactivemq.base="$CLUSTER_CONFIG_DIR/tmp" -Dactivemq.transportConnectors.server.uri="tcp://"$BROKERIP":0?maximumConnections=1000&wireFormat.maxFrameSize=104857600&jms.useAsyncSend=true&transport.daemon=true&trace=true" -Djava.awt.headless=true -DSTOP.PORT=8079 -DSTOP.KEY=geoserver -jar start.jar
