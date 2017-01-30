#
# Top-level component that manages the section tool & the various individual
# section components that get rendered.
#

React = require 'react'
SectionContainer = React.createFactory require '../section_container/index.coffee'
SectionTool = React.createFactory require '../section_tool/index.coffee'
{ div } = React.DOM

module.exports = React.createClass

  getInitialState: ->
    { editingIndex: null }

  componentDidMount: ->
    @props.sections.on 'add remove reset', => @forceUpdate()
    @props.sections.on 'add', @onNewSection

  componentDidUpdate: ->
    $(@getDOMNode()).find('.scribe-marker').remove()

  onSetEditing: (i) ->
    @setState editingIndex: i

  onNewSection: (section) ->
    @setState editingIndex: @props.sections.indexOf section

  convertImages: (section) ->
    image = {
      type: 'image_collection'
      images: [{
        type: section.get('type')
        url: section.get('url')
        caption: section.get('caption')
      }]
      layout: section.get('layout') or 'overflow_fillwidth'
    }
    section.clear()
    section.set image
    return section

  convertArtworks: (section) ->
    images = section.get('artworks').map (artwork, i) ->
      artwork.type = 'artwork'
      return artwork
    artworks = {
      type: 'image_collection'
      images: images
      layout: section.get('layout') or 'overflow_fillwidth'
    }
    section.clear()
    section.set(artworks)
    return section

  render: ->
    div {},
      div {
        className: 'edit-section-list' +
          (if @props.sections.length then ' esl-children' else '')
        ref: 'sections'
      },
        SectionTool { sections: @props.sections, index: -1 }
        @props.sections.map (section, i) =>
          if section.get('type') is 'image'
            section = @convertImages section
          if section.get('type') is 'artworks'
            section = @convertArtworks section
          [
            SectionContainer {
              sections: @props.sections
              section: section
              index: i
              editing: @state.editingIndex is i
              ref: 'section' + 1
              key: section.cid
              onSetEditing: @onSetEditing
            }
            SectionTool { sections: @props.sections, index: i }
          ]
