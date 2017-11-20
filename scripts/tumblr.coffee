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
#   hubot show me tumblr names - Shows the suggested blog names
#   hubot show me tumblr <count> - Shows the latest <count> tumblr photos (default is 1)
#
# Author:
#   pgieser

blogNames = process.env.HUBOT_TUMBLR_BLOG_NAMES.split(",")
apiKey = process.env.HUBOT_TUMBLR_API_KEY

queryNames = (msg) ->
  txt = "choose blog names:\n"
  for name in blogNames
    txt += "#{name}\n"
  msg.reply txt

buildPhotoAttachments = (msg, blog, post) ->
  attachments = []
  for photo in post.photos
    attachments.push({
      "image_url": "#{photo.original_size.url}"
      "thumb_url": "#{photo.alt_sizes[0].url}"
    })
  return attachments

buildVideoAttachments = (msg, blog, post) ->
  attachments = []
  if post.video_type == 'tumblr'
    attachments.push({
      "author_name": "#{blog.name} - #{blog.title}"
      "author_link": "#{blog.url}"
      "image_url": "#{post.thumbnail_url}"
      "thumb_url": "#{post.video_url}"
    })
  else
    attachments.push({
      "text": "#{post.caption}"
    })
  return attachments

buildTextAttachments = (msg, blog, post) ->

buildAudioAttachments = (msg, blog, post) ->

queryBlogs = (msg, blogName, limit, mediaType) ->
  if blogName == 'names'
    return

  msg.http("https://api.tumblr.com/v2/blog/#{blogName}.tumblr.com/posts/#{mediaType}")
    .query(api_key: apiKey, limit: limit)
    .get() (err, res, body) ->

      if err
        msg.send "Tumblr says: #{err}"
        return

      content = JSON.parse(body)

      if content.meta.status isnt 200
        msg.reply "Tumblr says: #{content.meta.msg}"
        return

      posts = content.response.posts

      for post in posts
        switch mediaType
          when 'photo' then attachments = buildPhotoAttachments(msg, content.response.blog, post)
          when 'video' then attachments = buildVideoAttachments(msg, content.response.blog, post)
          when 'text' then attachments = buildTextAttachments(msg, content.response.blog, post)
          when 'audio' then attachments = buildAudioAttachments(msg, content.response.blog, post)
          else
            msg.reply "unknown media type: #{mediaType}"
            return

        message = {
          text: "[LINK](#{post.post_url}) #{post.summary}"
          attachments: JSON.stringify attachments
          mrkdwn_in: ["text"]
        }
        msg.reply message

module.exports = (robot) ->

  robot.respond /show\s+(?:me\s+)?tumblr\s+names/i, (msg) ->
    queryNames msg

  robot.respond /show\s+(?:me\s+)?tumblr\s+(\S+)(?:\s+(\d))?(?:\s+(video|photo|text|audio))?/i, (msg) ->
    queryBlogs(msg, msg.match[1], msg.match[2] || 1, msg.match[3] || 'photo')
