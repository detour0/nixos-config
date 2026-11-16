# Window picker as a rofi script mode ("windows" in the mode switcher), workroom-aware.
# rofi runs this with ROFI_RETV=0 to get the list and with ROFI_RETV=1 after a selection,
# passing the row's hidden info ("<workspace> <con_id>") in ROFI_INFO.
# On select: switch to the window's workroom (workspace / 10), update $workroom for the
# number keys, then focus the window where it lives. Nothing is moved between outputs.
# Expects $workrooms_bin to be set by the Nix wrapper.

list_windows() {
  printf '\0prompt\x1fwindows\n'
  printf '\0no-custom\x1ftrue\n'

  # workspace, con_id, app, title
  swaymsg -t get_tree | jq -r '
    recurse(.nodes[]?, .floating_nodes[]?)
    | select(.type == "workspace" and .name != "__i3_scratch")
    | .name as $ws
    | recurse(.nodes[]?, .floating_nodes[]?)
    | select(.pid != null)
    | [
        $ws,
        .id,
        (.app_id // .window_properties.class // "?"),
        ((.name // "") | gsub("[\t\n]"; " "))
      ]
    | @tsv' |
    sort -t $'\t' -k1,1V |
    while IFS=$'\t' read -r ws id app title; do
      printf '%-4s %-16.16s %s\0icon\x1f%s\x1finfo\x1f%s %s\n' \
        "$ws" "$app" "$title" "${app,,}" "$ws" "$id"
    done
}

jump() {
  local ws id wr
  read -r ws id <<<"$1"
  [ -z "${id:-}" ] && return 0

  # Numbered workspaces belong to workroom ws/10; "n", "m" etc. are global
  if [[ "$ws" =~ ^[0-9]+$ ]] && ((ws >= 10)); then
    wr=$((ws / 10))
    "$workrooms_bin" switch "$wr"
    # sway skips variable expansion for the name in `set`, so this retargets $mod+1..9
    swaymsg "set \$workroom $wr" >/dev/null
  fi

  swaymsg "[con_id=$id] focus" >/dev/null
}

case "${ROFI_RETV:-0}" in
  0) list_windows ;;
  1) jump "${ROFI_INFO:-}" ;; # printing nothing closes rofi
  *) exit 0 ;;
esac
