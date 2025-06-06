FROM mcr.microsoft.com/mssql/server:2022-latest

RUN mkdir /tmp/initscripts

COPY *.s* . /tmp/initscripts

USER root
RUN chmod +x /tmp/initscripts/*.sh
USER mssql

ENTRYPOINT ["/tmp/initscripts/entrypoint.sh"]