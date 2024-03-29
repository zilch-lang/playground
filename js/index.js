'use strict'

let zilchEditor, nstarEditor
let split

document.addEventListener('DOMContentLoaded', e => {
  let tabbar = document.querySelector('#tabs')
  let colorToggle = document.querySelector('#toggle-dark')
  let runButton = document.querySelector('#run')
  let settingsButton = document.querySelector('#settings')

  let dropdown = document.querySelector('#settings-dropdown-content');

  let editorTab = document.querySelector('#code-editor-tab')
  let debugTab = document.querySelector('#debug-tab')
  let storage = window.localStorage

  let width = Math.floor(document.body.getBoundingClientRect().width)
  let height = Math.floor(document.body.getBoundingClientRect().height)

  window.addEventListener('resize', e => {
    // TODO: check if screen is higher (vertical split) or larger (horizontal split + class="flex flex-row")
    return true
  })

  document.querySelector('#editor-view').addEventListener('click', e => {
    if (!tabbar.classList.contains('bg-purple')) {
      ['db', 'dn'].map(c => editorTab.classList.toggle(c));
      ['grid-row2', 'dn'].map(c => debugTab.classList.toggle(c))

      tabbar.classList.toggle('bg-purple')
      tabbar.classList.toggle('bg-dark-gray')

      zilchEditor.refresh()
    }

    return true
  })
  document.querySelector('#compiler-view').addEventListener('click', e => {
    if (!tabbar.classList.contains('bg-dark-gray')) {
      ['db', 'dn'].map(c => editorTab.classList.toggle(c));
      ['grid-row2', 'dn'].map(c => debugTab.classList.toggle(c))

      tabbar.classList.toggle('bg-purple')
      tabbar.classList.toggle('bg-dark-gray')

      let headerHeight = document.querySelector('#nstar-editor-wrapper > div:first-child > div:first-child').clientHeight
      let nstarEditor_ = document.querySelector('#nstar-editor')

      nstarEditor_.style.setProperty('--local-remove-height', `${headerHeight}px`)
      nstarEditor_.classList.add('rem-some')
      nstarEditor.refresh()
    }

    return true
  })
  
  runButton.addEventListener('click', e => {
    if (runButton.disabled)
      return false

    let buttonIcon = runButton.querySelector('i')
    buttonIcon.classList.toggle('fa-play-circle')
    buttonIcon.classList.toggle('fa-stop-circle');

    ['bg-silver', 'bg-dark-green', 'dim', 'curna'].map(c => runButton.classList.toggle(c))
    runButton.disabled = true

    const restoreState = () => {
      runButton.disabled = false

      buttonIcon.classList.toggle('fa-play-circle')
      buttonIcon.classList.toggle('fa-stop-circle');

      ['bg-silver', 'bg-dark-green', 'dim', 'curna'].map(c => runButton.classList.toggle(c))
    }

    let zilchCode = zilchEditor.getValue()
    fetch('/compile', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ code: zilchCode }),
    })
      .then(res => {
        if (!res.ok) {
          throw new Error(`Response status: ${res.status}`)
        }
        return res.json()
      })
      .then(res => {
        document.querySelector('#stdout > pre code').innerText = res.stdout
        document.querySelector('#stderr > pre code').innerText = res.stderr
        nstarEditor.setValue(res.nstar)

        // TODO:
        // - show dialog box if `res.fail` is `true`
      })
      .catch(err => { alert(err.message) })
      .finally(() => { restoreState() })

    return true
  })
  colorToggle.addEventListener('click', e => {
    const darkMode = (storage.getItem('dark-mode') || '0') == 1;

    ['bg-gray', 'near-white', 'bg-near-white', 'gray'].map(c => e.target.classList.toggle(c))
    storage.setItem('dark-mode', darkMode ? 0 : 1);
    ['fa-sun', 'fa-moon'].map(c => e.target.querySelector('i').classList.toggle(c))

    const editorMode = darkMode ? 'xq-light' : 'nord'
    zilchEditor.setOption('theme', editorMode)
    nstarEditor.setOption('theme', editorMode);
    ['#code-editor-tab', '#debug-tab', '#nstar-editor-wrapper', '#program-output'].map(e => document.querySelector(e).classList.toggle('cm-s-nord'))
    Array.prototype.map.call(document.querySelectorAll('.divider'), e => ['black-70', 'white-70'].map(c => e.classList.toggle(c)))
    Array.prototype.map.call(document.querySelectorAll('.gutter'), e => e.classList.toggle('dark-gutter'));
    ['#stdout > pre', '#stderr > pre'].map(e => ['white', 'black'].map(c => document.querySelector(e).classList.toggle(c)));
    ['black', 'white', 'light-menu', 'dark-menu'].map(c => dropdown.classList.toggle(c));
  	['#compiler-options', '#stdin'].map(id => ['b--black-20', 'b--white-20'].map(c => document.querySelector(id).classList.toggle(c)))

    return true
  })

  const settingsClickCanceller = e => {
    if (e.target.matches('#settings-dropdown-content') || e.target.matches('#settings-dropdown-content *')) {
      return false
    }

		e.preventDefault();
    ['z-1', 'z-0', 'o-0', 'o-100'].map(c => dropdown.classList.toggle(c))
    document.removeEventListener('click', settingsClickCanceller)
    return true
  }
  settingsButton.addEventListener('click', e => {
    ['z-1', 'z-0', 'o-0', 'o-100'].map(c => dropdown.classList.toggle(c))

    setTimeout(() => document.addEventListener('click', settingsClickCanceller), 1)

    return true
  })

  zilchEditor = CodeMirror(document.querySelector('#zilch-editor'), {
    mode: "zilch",
    lineNumbers: true,
    indentUnit: 2,
    tabSize: 2,
    lineWrapping: true,
    spellcheck: false,
    autocorrect: false,
    autocomplete: false,
  })
  nstarEditor = CodeMirror(document.querySelector('#nstar-editor'), {
    mode: "nstar",
    lineNumbers: true,
    indentUnit: 2,
    tabSize: 2,
    readOnly: true,
    lineWrapping: true,
    spellcheck: false,
    autocorrect: false,
    autocomplete: false,
  })

  split = Split(['#nstar-editor-wrapper', '#program-output'], {
    snapOffset: 0,
    direction: 'vertical',
    onDragEnd: function (sizes) {
      nstarEditor.refresh()
    }
  })

  // setup the dark mode on loading
  const darkMode = (storage.getItem('dark-mode') || '0') == 1
  const editorTheme = darkMode ? 'nord' : 'xq-light'
  zilchEditor.setOption('theme', editorTheme)
  nstarEditor.setOption('theme', editorTheme);
  (darkMode ? ['gray', 'bg-near-white'] : ['near-white', 'bg-gray']).map(c => colorToggle.classList.toggle(c))
  colorToggle.querySelector('i').classList.toggle(darkMode ? 'fa-sun' : 'fa-moon')
  if (darkMode) {
    ['#code-editor-tab', '#debug-tab', '#nstar-editor-wrapper', '#program-output'].map(e => document.querySelector(e).classList.toggle('cm-s-nord'))
  }
  Array.prototype.map.call(document.querySelectorAll('.divider'), e => e.classList.toggle(darkMode ? 'white-70' : 'black-70'))
  if (darkMode) {
    Array.prototype.map.call(document.querySelectorAll('.gutter'), e => e.classList.toggle('dark-gutter'))
  }
  ['#stdout > pre', '#stderr > pre'].map(e => document.querySelector(e).classList.toggle(darkMode ? 'white' : 'black'))
  if (darkMode) {
  	['black', 'white', 'light-menu', 'dark-menu'].map(c => dropdown.classList.toggle(c));
  	['#compiler-options', '#stdin'].map(id => ['b--black-20', 'b--white-20'].map(c => document.querySelector(id).classList.toggle(c)))
  }
  
  zilchEditor.focus()
}, false);
