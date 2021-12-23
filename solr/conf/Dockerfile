FROM  solr:7.3.0
LABEL maintainer="dls@umn.edu"

ENV CONF_DIR /opt/solr/server/solr/cores/core/conf
RUN mkdir -p $CONF_DIR
WORKDIR $CONF_DIR
COPY --chown=solr:solr . .