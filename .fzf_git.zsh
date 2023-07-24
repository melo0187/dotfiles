is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf --multi --ansi --reverse --keep-right --no-sort --height 100% "$@" --border 
}

_gf() {
  is_in_git_repo || return
  #TODO return if no filechanges
  git -c color.status=always status | grep modified | sed 's/modified://' | sed -r 's/\s*//g' |
  fzf-down \
    --preview-window down:80% \
    --preview 'git diff --color=always HEAD -- {}'
}

# List all branches
_gr() {
  is_in_git_repo || return
  local parseKNUTH='$(grep -o "KNUTH-\w*" <<< {})'
  git branch -a --color=always --sort=committerdate | grep -v '/HEAD\s' | sed 's/remotes\///' | sed 's/^..//' | cut -d" " -f1 |
  fzf-down --tac --preview-window right:60% \
    --preview 'git log --color=always {}~..{} | head -'$LINES |
    sed 's/origin\///'
}

_gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --preview-window right:70% \
    --preview 'git show --color=always {} | head -'$LINES
}

_gh() {
  is_in_git_repo || return
  local selection=$(git log --graph --color=always --format="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --all |
  fzf-down \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show -s --color=always | head -'$LINES \
    --preview-window down:30%) 
  local githash=$(echo $selection | egrep -o '[a-f0-9]{7,}')
  local branches=$(echo "$selection" | grep -oP '(- \()\K((HEAD(, | -> )|tag:.*,)\K)?(.*?)(?=\))' | head -1 | grep -oP '[^,\\\s]*')
  #if selected has branch then list hash and branches. if selected contains only hash take hase. if nothing do nothing
  if [[ ! -z "$branches" ]] 
  then
	  echo $githash \\n$branches | fzf-down 
  else
	  [[ ! -z "$githash" ]] && echo $githash
  fi
}

# _gr() {
#   is_in_git_repo || return
#   git remote -v | awk '{print $1 "\t" $2}' | uniq |
#   fzf-down --tac \
#     --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
#   cut -d$'\t' -f1
# }


_gl() {
  is_in_git_repo || return
  git log --pretty='%C(bold magenta)%h %Creset%C(italic cyan)%an %Creset%C(white)%s' --color=always | fzf-down --preview 'git show $(cut -f 1 -d " " <<< {})~..$(cut -f 1 -d " " <<< {}) --color=always' | cut -f 1 -d " "
}

_gs() {
  is_in_git_repo || return
  git stash list | fzf-down --preview 'git stash show -p --color=always $(grep -o "stash@{.*}" <<< {})' | grep -oP "stash@{.*}" | sed -e "s/\\//"
}

join-lines() {
  local item
  while read item; do
    echo -n "${(q)item}"
  done
}

bind-git-helper() {
  local c
  for c in $@; do
    eval "fzf-g$c-widget() { local result=\$(_g$c | join-lines); zle reset-prompt; LBUFFER+=\$result }"
    eval "zle -N fzf-g$c-widget"
    eval "bindkey '^g^$c' fzf-g$c-widget"
  done
}

bind-git-helper f r t h l s
unset -f bind-git-helper

