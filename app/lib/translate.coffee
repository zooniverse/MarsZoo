$ = require 'jqueryify'
strings = require 'translations/en_us'

translate = (keys...) ->
  keys = keys[0].split '.' if keys.length is 1
  reference = strings

  for key in keys
    throw new Error "No translation for #{keys.join '.'}" unless reference[key]?
    reference = reference[key]

  reference

deepMixin = (base, mixin) ->
  # NOTE: This expects only strings and numbers nested in objects.
  for own key, value of mixin
    if typeof value in ['string', 'number']
      base[key] = value
    else
      deepMixin base[key], value

  base

translate.init = ([language]..., callback) ->
  gotLanguage = new $.Deferred
  gotLanguage.done ->
    for element in $('[data-i18n]')
      element = $(element)
      key = element.attr 'data-i18n'
      element.html translate key

    $(window).trigger 'translate-init'

    callback? strings

  if language
    $.getJSON "translations/#{language}.json", (translations) ->
      deepMixin strings, translations
      gotLanguage.resolve strings
  else
    gotLanguage.resolve strings

module.exports = translate
