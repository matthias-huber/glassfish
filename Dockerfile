FROM glassfish:latest

ENV INSPECTIT_VERSION 1.6.2.65

RUN wget ftp://ftp.novatec-gmbh.de/inspectit/releases/RELEASE.${INSPECTIT_VERSION}/inspectit-agent-sun1.5.zip -q \
	&& unzip inspectit-agent-sun1.5.zip -d /opt \
	&& apt-get clean \
	&& rm -rf /var/lib/apt \
	&& rm -f inspectit-agent-sun1.5.zip

RUN ln -s /opt/agent/inspectit-agent.jar glassfish/domains/domain1/lib/ext/
RUN ln -s /opt/agent/logging-config.xml glassfish/domains/domain1/lib/ext/
ENV INSPECTIT_AGENT_HOME /opt/agent
ENV INSPECTIT_CONFIG_HOME /opt/agent/active-config

RUN sed -i "s#\(</java-config>\)#<jvm-options>-Xbootclasspath/p:\${com\.sun\.aas\.instanceRoot}/lib/ext/inspectit-agent\.jar</jvm-options>\1#" glassfish/domains/domain1/config/domain.xml \
	&& sed -i "s#\(</java-config>\)#<jvm-options>-javaagent:\${com\.sun\.aas\.instanceRoot}/lib/ext/inspectit-agent\.jar</jvm-options>\1#" glassfish/domains/domain1/config/domain.xml \
	&& sed -i "s#\(</java-config>\)#<jvm-options>-Dinspectit.config=${INSPECTIT_CONFIG_HOME}</jvm-options>\1#" glassfish/domains/domain1/config/domain.xml

COPY run-with-inspectit.sh /run-with-inspectit.sh
VOLUME /opt/agent/active-config
CMD /run-with-inspectit.sh