'use strict'

let flask
let split

document.addEventListener('DOMContentLoaded', e => {
  let tabbar = document.querySelector('#tabs')
  let colorToggle = document.querySelector('#toggle-dark')

  let editorTab = document.querySelector('#code-editor-tab')
  let debugTab = document.querySelector('#debug-tab')
  let storage = window.localStorage

  document.querySelector('#editor-view').addEventListener('click', e => {
    if (!tabbar.classList.contains('bg-purple')) {
      ['db', 'dn'].map(c => editorTab.classList.toggle(c));
      ['db', 'dn'].map(c => debugTab.classList.toggle(c))

      tabbar.classList.toggle('bg-purple')
      tabbar.classList.toggle('bg-dark-gray')
    }
  })
  document.querySelector('#compiler-view').addEventListener('click', e => {
    if (!tabbar.classList.contains('bg-dark-gray')) {
      ['db', 'dn'].map(c => editorTab.classList.toggle(c));
      ['db', 'dn'].map(c => debugTab.classList.toggle(c))

      tabbar.classList.toggle('bg-purple')
      tabbar.classList.toggle('bg-dark-gray')
    }
  })
  document.querySelector('#run').addEventListener('click', e => {
    // TODO:
    // - Change icon to fa-stop-circle
    // - Get code and send a request to the backend
    // - Wait for request to end (correctly or timeout)
    // - Change icon back to fa-play
  })
  colorToggle.addEventListener('click', e => {
    const darkMode = (storage.getItem('dark-mode') || '0') == 1;

    ['bg-gray', 'near-white', 'bg-near-white', 'gray'].map(c => e.target.classList.toggle(c))
    storage.setItem('dark-mode', darkMode ? 0 : 1);
    ['fa-sun', 'fa-moon'].map(c => e.target.querySelector('i').classList.toggle(c))

    flask.setOption('theme', darkMode ? 'xq-light' : 'nord')
  })

  const darkMode = (storage.getItem('dark-mode') || '0') == 1;

//  split = new Split(['#code-editor-pane', '#debug-pane'], {
//    sizes: [75, 25],
//    minSizes: [200, 100],
//  })

  flask = CodeMirror(document.querySelector('#editor'), {
    mode: "haskell",
    lineNumbers: true,
    indentUnit: 2,
    tabSize: 2,
    lineWrapping: true,
    spellcheck: false,
    autocorrect: false,
    autocomplete: false,
  })

  flask.setOption('theme', darkMode ? 'nord' : 'xq-light');
  (darkMode ? ['gray', 'bg-near-white'] : ['near-white', 'bg-gray']).map(c => colorToggle.classList.toggle(c))
  colorToggle.querySelector('i').classList.toggle(darkMode ? 'fa-sun' : 'fa-moon')


}, false);
