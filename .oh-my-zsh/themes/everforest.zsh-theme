PROMPT="%(?:%F{#a7c080}%1{➜%} :%F{#e67e80}%1{➜%} ) %F{#83c092}%c%{$reset_color%}"
PROMPT+=' $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%F{#e69875}git: %F{#e67e80}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%F{#e67e80}) %{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{#83c092})"
