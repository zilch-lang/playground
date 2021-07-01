'use strict'

let flask
let split

document.addEventListener('DOMContentLoaded', e => {
//  split = new Split(['#code-editor-pane', '#debug-pane'], {
//    sizes: [75, 25],
//    minSizes: [200, 100],
//  })

  flask = new CodeFlask('#editor', {
    language: 'js',
    lineNumbers: true,
  })
}, false);
