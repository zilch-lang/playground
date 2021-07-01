'use strict'

let flask
let split

document.addEventListener('DOMContentLoaded', e => {
  let tabbar = document.querySelector('#tabs')

  document.querySelector('#editor-view').addEventListener('click', e => {
    if (!tabbar.classList.contains('bg-purple')) {
      // TODO:
      // - Set tab to #editor-tab
      tabbar.classList.toggle('bg-purple')
      tabbar.classList.toggle('bg-dark-gray')
      // - Change tab bar color (toggle `bg-purple` and `bg-dark-gray`)
    }
  })
  document.querySelector('#compiler-view').addEventListener('click', e => {
    if (!tabbar.classList.contains('bg-dark-gray')) {
      // TODO:
      // - Set tab to #debug-tab
      tabbar.classList.toggle('bg-purple')
      tabbar.classList.toggle('bg-dark-gray')
      // - Change tab bar color (toggle `bg-purple` and `bg-dark-gray`)
    }
  })
  document.querySelector('#run').addEventListener('click', e => {
    // TODO:
    // - Change icon to fa-stop-circle
    // - Get code and send a request to the backend
    // - Wait for request to end (correctly or timeout)
    // - Change icon back to fa-play
  })

//  split = new Split(['#code-editor-pane', '#debug-pane'], {
//    sizes: [75, 25],
//    minSizes: [200, 100],
//  })

  flask = new CodeFlask('#editor', {
    language: 'js',
    lineNumbers: true,
  })
}, false);
