# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

querystring = require 'querystring'

searchMap = (robot, msg) ->
  ak = process.env.BAIDU_MAP_AK
  title = msg.match[1]
  query = querystring.escape title
  width_l = 320
  height_l = 240
  width_s = 75
  height_s = 75
  zoom = 16
  message = {
    attachments: [{
      title: "#{title}",
      title_link: "https://api.map.baidu.com/geocoder?address=#{query}&output=html"
      color: "good",
      fallback: "#{title}",
      image_url: "https://api.map.baidu.com/staticimage/v2?ak=#{ak}&center=#{query}&width=#{width_l}&height=#{height_l}&zoom=#{zoom}&markers=#{query}",
      thumb_url: "https://api.map.baidu.com/staticimage/v2?ak=#{ak}&center=#{query}&width=#{width_s}&height=#{height_s}&zoom=#{zoom}&markers=#{query}"
    }],
    username: process.env.HUBOT_NAME,
    as_user: true
  }

  console.log JSON.stringify message
  msg.reply message

navigate = (robot, msg, mode) ->
  ak = process.env.BAIDU_MAP_AK

  origin_region = msg.match[1]
  origin = msg.match[2]
  region = origin_region
  destination_region = msg.match[3]
  destination = msg.match[4]

  console.log "mode=#{mode}, origin=#{origin}, dest=#{destination}"
  url = "http://api.map.baidu.com/direction/v1?mode=#{mode}&origin=#{origin}&destination=#{destination}&region=#{region}&origin_region=#{origin_region}&destination_region=#{destination_region}&output=json&ak=#{ak}"
  console.log url

  req = msg.http(url)

  req.header('Content-Length', 0)
  req.get() (err, res, body) ->
    if err
      msg.reply "Baidu says: #{err}"
      return

    json = JSON.parse(body)
    if json.status != 0
      msg.reply "Baidu says: #{json.message}"
      return

    if json.type == 2 # 起/终点唯一
      navigateCertain msg, mode, reuslt
    else
      navigateUncertain msg, mode, result

navigateCertain = (msg, mode, result) ->
  origin = result.origin
  destination = result.destination
  routes = result.routes
  taxi = result.taxi

  if routes == undefined || routes.length == 0
    msg.reply "路线查询失败"
    return
  attachments = []
  message = {
    "text": "从 *#{origin.wd}* 到 *#{destination.wd}*"
    username: process.env.HUBOT_NAME,
    as_user: true
    mrkdwnIn: ["text"]
  }

  console.log JSON.stringify message
  msg.reply message
  #  for step in routes[0].steps
  #    attachments.push({
  #      text: "#{step.instructions}",
  #      "mrkdwnIn": ["text"]
  #    })

  message = {attachments:attachments}
  console.log JSON.stringify message
  msg.reply message

navigateUncertain = (msg, mode, result) ->
  origin = result.origin
  destination = result.destination


module.exports = (robot) ->
  robot.respond /map?\s+(.+)/i, (msg) ->
    searchMap robot, msg

  robot.respond /开车\s*从\s*(\S+)\s+(.+)\s*到\s*(\S+)\s+(.+)\s*/i, (msg) ->
    navigate robot, msg, "driving"

  robot.respond /(?:走路|步行)\s*从\s*(\S+)\s+(.+)\s*到\s*(\S+)\s+(.+)\s*/i, (msg) ->
    navigate robot, msg, "walking"

  robot.respond /(?:公交)\s*从\s*(\S+)\s+(.+)\s*到\s*(\S+)\s+(.+)\s*/i, (msg) ->
    navigate robot, msg, "transit"

  robot.respond /(?:骑行|骑车)\s*从\s*(\S+)\s+(.+)\s*到\s*(\S+)\s+(.+)\s*/i, (msg) ->
    navigate robot, msg, "riding"
