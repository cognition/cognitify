#
# BASH completion for Hasicorp Terraform
#

_terraform() {
  local cur prev words cword
  _init_completion || return

  COMP_WORDBREAKS=${COMP_WORDBREAKS//=}

  local special i;
  for (( i=0; i < ${#words[@]}-1; i++ )); do
    if [[ ${words[i]} == @(apply|console|destroy|env|fmt|get|graph|import|init|output|plan|providers|push|refresh|show|taint|untaint|validate|version|workspace|debug|force-unlock|state) ]]; then
      special=${words[i]}
      break
    fi
  done

  if [[ -z $special ]]; then
    compopt +o nospace
    COMPREPLY=( $( compgen -W 'apply console destroy env fmt get graph import init output plan providers push refresh show taint untaint validate version workspace debug force-unlock state' -- $cur))
    return
  else
    compopt -o nospace
    COMPREPLY=( $( compgen -W '$( terraform "$special" -help | command grep  -e "^\s\+-" | _parse_help - )' -- $cur))
  fi

  case $prev in
    -out|-backup|-state|-state-out|-var-file|apply)
      _filedir
      return
      ;;
    -target)
      unset COMPREPLY
      return
      ;;
  esac

  if [[ $cur == "=" ]] && ([[ $prev == "-lock" ]] || [[ $prev == "-input" ]]); then
      COMPREPLY=( $( compgen -W '-lock=true -lock=false' -- $cur))
  fi

}

complete -F _terraform terraform
