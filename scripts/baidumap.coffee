# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

searchMap = (robot, msg) ->
  ak = process.env.BAIDU_MAP_AK
  query = msg.match[1]
  width = 640
  height = 480
  zoom = 17
  msg.send({
    attachments: [{
      title: "map for #{query}",
      color: "good",
      fallback: "map for #{query}",
      image_url: "http://api.map.baidu.com/staticimage/v2?ak=#{ak}&center=#{query}&width=#{width}&height=#{height}&zoom=#{zoom}&markers=#{query}"
    }],
    username: process.env.HUBOT_NAME,
    as_user: true
  });

module.exports = (robot) ->
  robot.respond /map?\s+(.+)/i, (msg) ->
    searchMap robot, msg

