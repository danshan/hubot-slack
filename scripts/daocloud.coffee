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
#   hubot dc load app <app> - 获取单个 App
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
        title: "#{app.name} : #{app.id}",
        text: "#{app.package.image} : *#{app.release_name}* : `#{app.state}`",
        color: (chooseColor app.state),
        mrkdwn_in: ["text"]
      })
      if attachments.length >= 30
        break;

    message = {
      attachments: attachments,
      username: process.env.HUBOT_NAME,
      as_user: true,
      mrkdwn_in: ["text"]
    }
    console.log JSON.stringify message
    msg.reply message

loadApp = (msg) ->
  query = msg.match[1]

  token = process.env.DAOCLOUD_TOKEN
  url = "https://openapi.daocloud.io/v1/apps/#{query}"
  req = msg.http(url)
  req.header("Authorization", "token " + token)

  req.get() (err, res, body) ->
    if (err)
      msg.reply "DaoCloud says: #{err}"
      return

    json = JSON.parse(body)
    console.log body
    if (res.statusCode < 200 || res.statusCode >= 300)
      sendErr msg, json.error_id, json.message
      return

    command = ""
    if json.config.command != undefined
      command = json.config.command
    ports = []
    for port in json.config.expose_ports
      ports.push("#{port.host_port}:#{port.container_port}")

    attachments = []
    attachments.push({
      title: "#{json.name}",
      text: "#{json.package.image} : *#{json.release_name}* : `#{json.state}`\n*command:* #{command}\n*ports*: #{ports}",
      color: (chooseColor json.state),
      mrkdwn_in: ["text"]
    })

    message = {
      attachments: attachments,
      username: process.env.HUBOT_NAME,
      as_user: true,
      mrkdwn_in: ["text"]
    }
    console.log JSON.stringify message
    msg.reply message

chooseColor = (state) ->
  if /running/i.test state
    return "good"
  if /stopped/i.test state
    return "danger"
  return "warning"

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

  robot.respond /dc\s+load\s+app\s+(\S+)/i, (msg) ->
    loadApp msg
