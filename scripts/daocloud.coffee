# Description:
#   对接daocloud api
#
# Dependencies:
#
# Configuration:
#   DAOCLOUD_TOKEN
#
# Commands:
#   hubot dc list apps - 获取用户的 app 列表
#
# Notes:
#
# Author:
#   danshan

querystring = require 'querystring'


listApps = (msg) ->
  token = process.env.DAOCLOUD_TOKEN
  url = "https://openapi.daocloud.io/v1/apps"
  req = msg.http(url)
  req.header("Authorization", "token " + token)

  req.get() (err, res, body) ->
    if (err)
      msg.reply "DaoCloud says: #{err}"
      return

    json = JSON.parse(body)
    if (res.statusCode < 200 || res.statusCode >= 300)
      sendErr msg, json.error_id, json.message
      return

    attachments = []
    for app in json.app
      attachments.push({
        title: "*#{app.name}* : #{app.release_name} : `#{app.state}`",
        text: app.package.image,
        color: "good"
      })
      if attachments.length >= 30
        break;

    message = {
      attachments: attachments,
      username: process.env.HUBOT_NAME,
      as_user: true
    }
    console.log JSON.stringify message
    msg.reply message

sendErr = (msg, error_id, error_message) ->
  message = {
    attachments: [{
      title: "#{error_id}",
      text: "#{error_message}"
      color: "bad",
      fallback: "#{error_id}"
    }],
    username: process.env.HUBOT_NAME,
    as_user: true
  }
  console.error JSON.stringify message
  msg.reply message

module.exports = (robot) ->
  robot.respond /dc\s+list\s+apps/i, (msg) ->
    listApps msg