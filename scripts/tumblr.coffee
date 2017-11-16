# Description:
#   Display photos from a Tumblr blog
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_TUMBLR_BLOG_NAMES
#   HUBOT_TUMBLR_API_KEY
#
# Commands:
#   hubot show me tumblr <count> - Shows the latest <count> tumblr photos (default is 1)
#
# Author:
#   pgieser

module.exports = (robot) ->

  blog_names = process.env.HUBOT_TUMBLR_BLOG_NAMES.split(",")
  api_key   = process.env.HUBOT_TUMBLR_API_KEY

  robot.respond /show\s+(?:me\s+)?tumblr\s+names/i, (msg) ->
    txt = "choose blog names:\n"
    for name in blog_names
      txt += "#{name}\n"
    msg.reply txt

  robot.respond /show\s+(?:me\s+)?tumblr\s+(\S+)(?:\s+(\d+))?/i, (msg) ->
    blog_name = msg.match[1]
    count = msg.match[2] || 1
    if blog_name == 'names'
      return

    msg.http("http://api.tumblr.com/v2/blog/#{blog_name}.tumblr.com/posts/photo")
      .query(api_key: api_key, limit: count)
      .get() (err, res, body) ->

        if err
          msg.send "Tumblr says: #{err}"
          return

        content = JSON.parse(body)

        if content.meta.status isnt 200
          msg.send "Tumblr says: #{content.meta.msg}"
          return

        posts = content.response.posts

        for post in posts
          if posts.length is 1
            msg.send post.caption
          for photo in post.photos
            msg.send photo.original_size.url
