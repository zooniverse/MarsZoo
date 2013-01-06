{Stack} = require 'spine/lib/manager'
SubPage = require './sub_page'
translate = require 'translate'
developersView = require 'views/developers'
scientistsView = require 'views/scientists'

class AboutPage extends Stack
  className: "#{Stack::className} about-page"

  controllers:
    index: class extends SubPage then content: translate 'about.index'
    scientists: class extends SubPage then content: scientistsView @
    developers: class extends SubPage then content: developersView @
    stargazingLive: class extends SubPage then content: translate 'about.stargazingLive'

  routes:
    '/about': 'index'
    '/about/scientists': 'scientists'
    '/about/developers': 'developers'
    '/about/stargazing-live': 'stargazingLive'

  default: 'index'

module.exports = AboutPage
