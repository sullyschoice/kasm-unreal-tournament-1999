# Kasm base image tag. Images built on 1.20+ bases do not run on Kasm 1.19 and older.
#   1.19.0-rolling-daily -> Kasm 1.19 and older (default)
#   develop              -> Kasm 1.20 (until a 1.20 rolling base tag is published)
ARG BASE_TAG=1.19.0-rolling-daily

FROM kasmweb/core-debian-trixie:${BASE_TAG}
USER root

ENV HOME=/home/kasm-default-profile
ENV STARTUPDIR=/dockerstartup
ENV INST_SCRIPTS=$STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

COPY ./src/ut99 $INST_SCRIPTS/ut99/
RUN bash $INST_SCRIPTS/ut99/install_ut99.sh  && rm -rf $INST_SCRIPTS/ut99/

COPY ./src/ut99/custom_startup.sh $STARTUPDIR/custom_startup.sh
RUN chmod +x $STARTUPDIR/custom_startup.sh

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME=/home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
