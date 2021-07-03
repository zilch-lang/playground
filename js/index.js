'use strict'

let zilchEditor, nstarEditor
let split

document.addEventListener('DOMContentLoaded', e => {
  let tabbar = document.querySelector('#tabs')
  let colorToggle = document.querySelector('#toggle-dark')

  let editorTab = document.querySelector('#code-editor-tab')
  let debugTab = document.querySelector('#debug-tab')
  let storage = window.localStorage

  window.addEventListener('resize', e => {
    // TODO: check if screen is higher (vertical split) or larger (horizontal split + class="flex flex-row")
    return true
  })

  document.querySelector('#editor-view').addEventListener('click', e => {
    if (!tabbar.classList.contains('bg-purple')) {
      ['db', 'dn'].map(c => editorTab.classList.toggle(c));
      ['grid', 'dn'].map(c => debugTab.classList.toggle(c))

      tabbar.classList.toggle('bg-purple')
      tabbar.classList.toggle('bg-dark-gray')

      zilchEditor.refresh()
    }

    return true
  })
  document.querySelector('#compiler-view').addEventListener('click', e => {
    if (!tabbar.classList.contains('bg-dark-gray')) {
      ['db', 'dn'].map(c => editorTab.classList.toggle(c));
      ['grid', 'dn'].map(c => debugTab.classList.toggle(c))

      tabbar.classList.toggle('bg-purple')
      tabbar.classList.toggle('bg-dark-gray')

      nstarEditor.refresh()
    }

    return true
  })
  document.querySelector('#run').addEventListener('click', e => {
    // TODO:
    // - Change icon to fa-stop-circle
    // - Get code and send a request to the backend
    // - Wait for request to end (correctly or timeout)
    // - Change icon back to fa-play

    return true
  })
  colorToggle.addEventListener('click', e => {
    const darkMode = (storage.getItem('dark-mode') || '0') == 1;

    ['bg-gray', 'near-white', 'bg-near-white', 'gray'].map(c => e.target.classList.toggle(c))
    storage.setItem('dark-mode', darkMode ? 0 : 1);
    ['fa-sun', 'fa-moon'].map(c => e.target.querySelector('i').classList.toggle(c))

    zilchEditor.setOption('theme', darkMode ? 'xq-light' : 'nord')

    return true
  })

  const darkMode = (storage.getItem('dark-mode') || '0') == 1;

  zilchEditor = CodeMirror(document.querySelector('#zilch-editor'), {
    mode: "haskell",
    lineNumbers: true,
    indentUnit: 2,
    tabSize: 2,
    lineWrapping: true,
    spellcheck: false,
    autocorrect: false,
    autocomplete: false,
  })
  nstarEditor = CodeMirror(document.querySelector('#nstar-editor'), {
    mode: "haskell",
    lineNumbers: true,
    indentUnit: 2,
    tabSize: 2,
    readOnly: true,
    lineWrapping: true,
    spellcheck: false,
    autocorrect: false,
    autocomplete: false,
  })

  // TODO: check if screen is higher (vertical split) or larger (horizontal split)
  split = Split({
    minSize: 300,
    columnGutters: [{
      track: 1,
      element: document.querySelector('.gutter-debug-tab'),
    }],
    expandToMin: true,
  })

  zilchEditor.setOption('theme', darkMode ? 'nord' : 'xq-light');
  (darkMode ? ['gray', 'bg-near-white'] : ['near-white', 'bg-gray']).map(c => colorToggle.classList.toggle(c))
  colorToggle.querySelector('i').classList.toggle(darkMode ? 'fa-sun' : 'fa-moon')
}, false);
