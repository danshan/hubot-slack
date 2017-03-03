# hubot-slack

[![Build Status](https://travis-ci.org/danshan/hubot-docker.svg?branch=master)](https://travis-ci.org/danshan/hubot-docker)
[![](https://images.microbadger.com/badges/image/danshan/hubot-docker.svg)](https://microbadger.com/images/danshan/hubot-docker "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/danshan/hubot-docker.svg)](https://microbadger.com/images/danshan/hubot-docker "Get your own version badge on microbadger.com")


hubot-slack:
  image: daocloud.io/danshan/hubot-slack:latest
  privileged: false
  restart: always
  environment:
  - HUBOT_SLACK_TOKEN=xoxb-149219387972-wYLwkLYEMYgGq0wPARytjwMx
  - HUBOT_LOG_LEVEL=debug
  - HUBOT_NAME=siri
