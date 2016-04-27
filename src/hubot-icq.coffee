try
  {Robot,Adapter,TextMessage,User} = require 'hubot'
catch
  prequire = require('parent-require')
  {Robot,Adapter,TextMessage,User} = prequire 'hubot'
  

ICQ = require('node-icq')

class Icq extends Adapter

  constructor: ->
    super
    @robot.logger.info "Constructor"

  send: (user, strings...) ->
    @robot.logger.info "Send"
    for str in strings
      @im.send user.user.id, str

  reply: (user, strings...) ->
    console.log 'reply'
    @robot.logger.info "Reply"

  run: ->
    @robot.logger.info "Run"
    im = new ICQ(
      "uin": process.env.HUBOT_ICQ_UIN,
      "password": process.env.HUBOT_ICQ_PASSWORD,
      "token": "ic1rtwz1s1Hj1O0r"
    )
    im.on('session:start', =>
      console.log 'session:start'
      im.setState('online')
      @emit "connected"
    )

    im.on('session:end', (endCode) =>
        @robot.logger.info('session ended: ' + endCode);
    );

    im.on('session:authn_required', =>
      @robot.logger.error('session fail')
      @im.reconnect(5000)
    )

    im.on('session:bad_request', =>
      @robot.logger.error('session fail')
      @im.reconnect(5000)
    )

    im.on('session:rate_limit', =>
        @robot.logger.error('session fail - rate limit');
        im.disconnect();
        setTimeout((-> im.connect()) , 30*60*1000);
    );

    im.on('im:auth_request', (auth_request) =>
      im.usersAdd(auth_request.uin, ->
        im.emit('im:message', auth_request)
      )
    )

    im.on('im:message', (message) =>
      user = @robot.brain.userForId message.uin
      @receive new TextMessage(user, message.text, 'messageId')
    )

    im.connect();
    @im = im


exports.use = (robot) ->
  new Icq robot