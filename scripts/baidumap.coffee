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
  width_l = 640
  height_l = 480
  width_s = 320
  height_s = 240
  zoom = 16
  msg.reply({
    attachments: [{
      title: "#{title}",
      title_link: "http://api.map.baidu.com/geocoder?address=#{query}&output=html"
      color: "good",
      fallback: "#{title}",
      image_url: "http://api.map.baidu.com/staticimage/v2?ak=#{ak}&center=#{query}&width=#{width_l}&height=#{height_l}&zoom=#{zoom}&markers=#{query}",
      thumb_url: "http://api.map.baidu.com/staticimage/v2?ak=#{ak}&center=#{query}&width=#{width_s}&height=#{height_s}&zoom=#{zoom}&markers=#{query}"
    }],
    username: process.env.HUBOT_NAME,
    as_user: true
  });

navigate = (robot, msg, mode) ->
  ak = process.env.BAIDU_MAP_AK

  if mode == "driving"
    origin_region = msg.match[1]
    origin = msg.match[2]
    destination_region = msg.match[3]
    destination = msg.match[4]
  else
    origin = msg.match[1]
    destination = msg.match[2]

  console.log "mode=#{mode}, origin=#{origin}, dest=#{destination}"
  url = "http://api.map.baidu.com/direction/v1?mode=#{mode}&origin=#{origin}&destination=#{destination}&origin_region=#{origin_region}&destination_region=#{destination_region}&output=json&ak=#{ak}"
  console.log url

  req = msg.http(url)

  req.header('Content-Length', 0)
  req.get() (err, res, body) ->
    if err
      msg.reply "Baidu says: #{err}"
    else if 200 <= res.statusCode < 400 # Or, not an error code.
      msg.reply body
    else
      msg.reply "Baidu says: Status #{res.statusCode} #{body}"



module.exports = (robot) ->
  robot.respond /map?\s+(.+)/i, (msg) ->
    searchMap robot, msg

  robot.respond /开车\s*从(\S+)\s+(.+)到(\S+)\s+(.+)/i, (msg) ->
    navigate robot, msg, "driving"

  robot.respond /(?:走路|步行)\s*从(.+)到(.+)/i, (msg) ->
    navigate robot, msg, "walking"

  robot.respond /(?:公交)\s*从(.+)到(.+)/i, (msg) ->
    navigate robot, msg, "transit"

  robot.respond /(?:骑行|骑车)\s*从(.+)到(.+)/i, (msg) ->
    navigate robot, msg, "riding"
