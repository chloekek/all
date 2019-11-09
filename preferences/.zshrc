ga() { git add "$@" }
gA() { git add -A "$@" }
gc() { git commit "$@" }
gca() { git commit --amend }
gd() { git diff "$@" }
gp() { git push "$@" }
gpf() { git push -f "$@" }
gs() { git status "$@" }

export MANWIDTH=80
export BROWSER=firefox
