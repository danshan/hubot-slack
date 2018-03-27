querystring = require 'querystring'

serverList = (msg) ->
  apikey = process.env.HUBOT_VULTR_APIKEY
  url = 'https://api.vultr.com/v1/server/list'
  req = msg.http(url)
  req.header("API-Key", apikey)

  req.get() (err, res, body) ->
    if (err)
      console.log err
      msg.reply "Vultr says: #{err}"
      return

    if (res.statusCode < 200 || res.statusCode >= 300)
      console.log body
      sendErr msg, body
      return

    console.log body
    json = JSON.parse(body)
    attachments = []
    for serverKey, server of json
      attachments.push({
        title: "#{server.SUBID}",
        title_link: "#{server.kvm_url}",
        text: "*#{server.main_ip}* - `#{server.server_state}` - #{server.label}",
        fields: [
          {title: "SUBID", value: "#{server.SUBID}", short: true},
          {title: "os", value: "#{server.os}", short: true},
          {title: "ram", value: "#{server.ram}", short: true},
          {title: "disk", value: "#{server.disk}", short: true},
          {title: "main ip", value: "#{server.main_ip}", short: true},
          {title: "vcpu count", value: "#{server.vcpu_count}", short: true},
          {title: "location", value: "#{server.location}", short: true},
          {title: "DCID", value: "#{server.DCID}", short: true},
          {title: "server state", value: "#{server.server_state}", short: true},
          {title: "internal ip", value: "#{server.internal_ip}", short: true}
        ],
        color: (chooseColor server.server_state),
        mrkdwn_in: ["text"]
      })
    message = {
      attachments: JSON.stringify attachments,
      username: process.env.HUBOT_NAME,
      as_user: true,
      mrkdwn_in: ["text"]
    }
    msg.reply message

accountInfo = (msg) ->
  apikey = process.env.HUBOT_VULTR_APIKEY
  url = 'https://api.vultr.com/v1/account/info'
  req = msg.http(url)
  req.header("API-Key", apikey)

  req.get() (err, res, body) ->
    if (err)
      msg.reply "Vultr says: #{err}"
      return

    if (res.statusCode < 200 || res.statusCode >= 300)
      sendErr msg, body
      return

    json = JSON.parse(body)
    attachments = []
    attachments.push({
      fields: [
        {title: "balance", value: "$#{json.balance}", short: true},
        {title: "pending charges", value: "$#{json.pending_charges}", short: true},
        {title: "last payment date", value: "#{json.last_payment_date}", short: true},
        {title: "last payment amount", value: "$#{json.last_payment_amount}", short: true},
      ],
      mrkdwn_in: ["text"]
    })
    message = {
      attachments: JSON.stringify attachments,
      username: process.env.HUBOT_NAME,
      as_user: true,
      mrkdwn_in: ["text"]
    }
    msg.reply message

chooseColor = (state) ->
  # none | locked | installingbooting | isomounting | ok
  if /none/i.test state
    return "good"
  if /locked/i.test state
    return "danger"
  if /installingbooting/i.test state
    return "warning"
  if /isomounting/i.test state
    return "warning"
  if /ok/i.test state
    return "good"
  return "warning"

sendErr = (msg, error_message) ->
  message = {
    attachments: [{
      title: "valtr api failed",
      text: "#{error_message}"
      color: "bad",
      fallback: "valtr api failed"
    }],
    username: process.env.HUBOT_NAME,
    as_user: true
  }
  console.log JSON.stringify message
  msg.reply message

module.exports = (robot) ->

  robot.respond /vultr server list/i, (msg) ->
    serverList(msg)

  robot.respond /vultr account info/i, (msg) ->
    accountInfo(msg)
