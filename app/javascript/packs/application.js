import 'selectize/dist/js/selectize.min.js';
import 'rangeslider.js/dist/rangeslider.js';

import '../src/libs/bootstrap-markdown.js';
import 'jquery.hotkeys/jquery.hotkeys.js';

import '../src/changelog_admin/referenceable_search.js';
import '../src/blog_post.js';
import '../src/buttons.js';
import '../src/code_snippet.js';
import '../src/editable-text.js';
import '../src/image-preview.js';
import '../src/landing-page.js';
import '../src/modal.js';
import '../src/my-track-mentored.js';
import '../src/new-editable-text.js';
import '../src/options.js';
import '../src/selectize.js';
import '../src/selects.js';
import '../src/solution.js';
import '../src/tabs.js';
import '../src/walkthrough.js';
import '../src/experiment-solution.js';

window.$ = window.jQuery = require("jquery");

window.Rails = require("@rails/ujs")
window.Rails.start()

require("@rails/activestorage").start()
require("channels")
