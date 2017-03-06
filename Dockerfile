FROM danshan/hubot-docker
MAINTAINER Dan <i@shanhh.com>

ENV BOTDIR /opt/data/bot
ENV HUBOT_USER hubot
CMD rm ${BOTDIR}/external-scripts.json

USER ${HUBOT_USER}
WORKDIR ${BOTDIR}

CMD rm -rf scripts
ADD scripts scripts
ENTRYPOINT ["/bin/sh", "-c", "bin/hubot -a slack -n '$HUBOT_NAME'"]


