FROM danshan/hubot-docker
MAINTAINER Dan <i@shanhh.com>

ENV BOTDIR /opt/data/bot
ENV HUBOT_USER hubot

USER ${HUBOT_USER}
WORKDIR ${BOTDIR}

ENTRYPOINT ["/bin/sh", "-c", "bin/hubot -a slack -n '$HUBOT_NAME'"]


