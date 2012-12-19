{Controller} = require 'spine'
{Stack} = require 'spine/lib/manager'

class SubPage extends Controller
  className: 'sub-page'

  content: ''

  constructor: ->
    super
    @html @content

  activate: ->
    super

    for controller of @stack.stack.controllers
      controller = @stack.stack[controller]
      return unless controller?

      if controller is @stack
        controller.activate()
      else
        controller.deactivate()

class AboutPage extends Stack
  className: "#{Stack::className} about-page"

  controllers:
    index: class extends SubPage then content: 'This is the about page index!'
    research: class extends SubPage then content: 'This is the research page!'
    scientists: class extends SubPage then content: 'This is the scientists page!'

  routes:
    '/about': 'index'
    '/about/research': 'research'
    '/about/scientists': 'scientists'

  default: 'index'

module.exports = AboutPage