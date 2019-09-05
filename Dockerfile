FROM bitnami/postgresql:11
LABEL maintainer "Xavi Torelló <info@xaviertorello.cat>"

USER root

ENV POSTGIS_VERSION=2.5.3

RUN install_packages wget gcc make build-essential libxml2-dev libgeos-dev libproj-dev libgdal-dev \
    && cd /tmp \
    && wget "http://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz" \
    && export C_INCLUDE_PATH=/opt/bitnami/postgresql/include/:/opt/bitnami/common/include/ \
    && export LIBRARY_PATH=/opt/bitnami/postgresql/lib/:/opt/bitnami/common/lib/ \
    && export LD_LIBRARY_PATH=/opt/bitnami/postgresql/lib/:/opt/bitnami/common/lib/ \
    && tar zxf postgis-*.tar.gz && cd postgis-* \
    && ./configure --with-pgconfig=/opt/bitnami/postgresql/bin/pg_config \
    && make \
    && make install \
    && apt-get remove --purge --auto-remove -y wget build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/postgis*

RUN echo '-- Enable PostGIS (includes raster)\n\
CREATE EXTENSION postgis;\n\
-- Enable Topology\n\
CREATE EXTENSION postgis_topology;\n\
-- Enable PostGIS Advanced 3D\n\
-- and other geoprocessing algorithms\n\
-- sfcgal not available with all distributions\n\
CREATE EXTENSION postgis_sfcgal;\n\
-- fuzzy matching needed for Tiger\n\
CREATE EXTENSION fuzzystrmatch;\n\
-- rule based standardizer\n\
CREATE EXTENSION address_standardizer;\n\
-- example rule data set\n\
CREATE EXTENSION address_standardizer_data_us;\n\
-- Enable US Tiger Geocoder\n\
CREATE EXTENSION postgis_tiger_geocoder;\n\
' >> activate_postgis.sql \
    && sed -i 's;postgresql_custom_init_scripts;info "Activating PostGIS extensions"\ncp activate_postgis.sql docker-entrypoint-initdb.d/\npostgresql_custom_init_scripts;g' setup.sh

USER 1001
