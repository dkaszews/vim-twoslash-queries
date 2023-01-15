# vim-twoslash-queries
(Neo)Vim port of [**vscode-twoslash-queries**](https://github.com/orta/vscode-twoslash-queries),
uses `^?` comments to "pin" [**YCM**](https://github.com/ycm-core/YouCompleteMe) symbol info.
It should work with all languages for which you have semantic completer installed.

## Usage
Under a line with a symbol you would like to preview, add a comment with `^?` pointing somewhere at the symbol. Examples:

```ts
const x = 1 + 2;
//    ^?
```

```python
def add(a, b):
    return a + b

add(1, 2)
#^?
```

Then run `TwoslashQueriesUpdate`, invoke `<Plug>(TwoslashQueriesUpdate)` or save the file with [`onsave`](#onsave) enabled.
The above becomes:

```ts
const x = 1 + 2;
//    ^?:  const x: number
```

```python
def add(a, b):
    return a + b

x = add(1, 2)
    #^?:  def add(a, b)
```

You can have multiple such comments in the file (that's the whole point!).
Aside from whitespace, there should be nothing on the line before the comment and between the comment character(s) and `^?`.

## Installation
With [`vim-plug`](https://github.com/junegunn/vim-plug) add to your `.vimrc`:

```
call plug#begin()
Plug 'ycm-core/YouCompleteMe'
Plug 'dkaszews/vim-twoslash-queries'
call plug#end()
```

## Configuration
All configuration is done via `twoslash_queries_config` dictionary.
At global level, they are grouped by `&filetype` with `*` used as fallback.
At buffer level, they all apply to current `&filetype`.
Options are looked up in the following order:
1. If `b:twoslash_queries_config` exists and `b:twoslash_queries_config[optname]` exists, return it.
1. If `g:twoslash_queries_config[&filetype]` exists and `b:twoslash_queries_config[&filetype][optname]` exists, return it.
1. Return `twoslash_queries_config['*'][optname]`.

The global config is merged with a default one for any `&filetype`s that are not defined, and for any options in `*` that are not defined.

Examples:
```viml
" In Python, pin documentation instead of default `GetHover`
let g:twoslash_queries_config = { 'python': { 'commands': [ 'GetDoc' ] } }

" In all languages, enable automatic update on save
let g:twoslash_queries_config = { '*': { 'onsave': 1 } }

" Disable automatic update on save in current buffer only
let b:twoslash_queries_config = { 'onsave': 1 }
```

### Options
#### `comment`
Character(s) denoting a single line comment.
For example, in C-like languages it is `//`, in Python, bash and PowerShell it `#`.

_string, default `'//'`, Python `'#'`_

#### `commands`
Array of [`YcmCompleter` subcommands](https://github.com/ycm-core/YouCompleteMe#ycmcompleter-subcommands) in order of preference.
First subcommand to return a non-empty result is used, errors are silenced.

_string array, default `[ 'GetHover', 'GetType', 'GetDoc' ]`_

#### `onsave`
Run `TwoslashQueriesUpdate` automatically whenever the buffer is saved.

_bool, default `0`_

## Commands and functions
All functions are prefixed with `twoslash_queries#`.
All commands are prefixed with `TwoslashQueries` and have a `<Plug>(...)` normal mapping with the same name.

####  `TwoslashQueriesUpdate`, `twoslash_queries#update()`
Update all pins with queries, as shown in [usage](#usage).

#### `twoslash_queries#update_on_save()`
Update if `onsave` is enabled for current buffer/filetype.
This is used by a `BufPostWrite` autocommand.

#### `twoslash_queries#get_opt(name)`
Return value of option `name` with the same lookup rules described in [ configuration](#configuration).

#### `twoslash_queries#invoke_ycm_command()`
Invoke preferred **YCM** command at the position of the cursor, with preference described in [options/`commands`](#commands).

## FAQ
#### Why `TwoslashQueriesUpdate` freezes vim for a second?
Current implementation is blocking, as the cursor needs to jump around.
This may be more noticeable in bigger files and with more pins.

#### Why my buffer never shows it is saved?
The query result is appended as a comment, so if you have `onsave` enabled, the buffer will get modified immediately after getting saved.
This should have no real impact on your workflow.

#### Can I add multiple pins for a single line?
Currently not, but it is on the roadmap.

#### Can the pin adjust to the symbol as it moves around?
Currently not, but alternative pin syntax to work around this is on the roadmap.

#### How can I quickly see query result that is off the screen?
Ability to display query results in a separate buffer is on the roadmap.

#### Do I need **YCM**, or can I use a different completer plugin?
Configuration to allow other plugins and custom queries is on the roadmap.

