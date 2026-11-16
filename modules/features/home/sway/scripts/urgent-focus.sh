# Pull urgent windows to the focused output.
# Apps that ask for activation (e.g. clicking a dunst notification) only get
# marked urgent by sway. This moves the window's workspace onto the output you
# are looking at and focuses the window. Workspaces already visible somewhere
# are focused in place instead of moved.

swaymsg -t subscribe -m '["window"]' |
  jq --unbuffered -r 'select(.change == "urgent" and .container.urgent) | .container.id' |
  while read -r id; do
    tree=$(swaymsg -t get_tree)
    ws=$(jq -r --argjson id "$id" '
      first(
        recurse(.nodes[]?, .floating_nodes[]?)
        | select(.type == "workspace")
        | select(any(recurse(.nodes[]?, .floating_nodes[]?); .id == $id))
        | .name
      ) // empty' <<<"$tree")
    [ -z "$ws" ] && continue

    focused_out=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')
    visible=$(swaymsg -t get_workspaces | jq -r --arg ws "$ws" '.[] | select(.name == $ws) | .visible')

    if [ "$visible" = "true" ]; then
      swaymsg "[con_id=$id] focus" >/dev/null
    else
      swaymsg "[con_id=$id] move workspace to output \"$focused_out\"; [con_id=$id] focus" >/dev/null
    fi
  done
