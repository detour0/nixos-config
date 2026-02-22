import sys
import json
import subprocess
import logging

logging.basicConfig(
    filename='/tmp/workroom.log',
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

logging.debug(f"sys.argv: {sys.argv}")

MULTIPLIER = 10

def compute_ws_num(workroom: int, output_index: int) -> int:
    return (workroom * MULTIPLIER) + (output_index + 1)

def swaymsg(command: str) -> None:
    logging.debug(f"Executing: swaymsg {command}")
    subprocess.run(['swaymsg', command], stdout=subprocess.DEVNULL)

def get_outputs() -> list[dict[str, Any]]:
    # Get all outputs in JSON format
    out = subprocess.check_output(['swaymsg', '-t', 'get_outputs', '-r'])
    outputs = json.loads(out)
    # Filter for active outputs and sort them by x position (Left to Right)
    active = [o for o in outputs if o['active']]
    active.sort(key=lambda o: o['rect']['x'])
    logging.debug(f"Number of active outputs: {len(active)}")
    return active

def switch_project(current_wr: int, target_wr: int) -> None:
    # # Avoid unnacessary switching to already active workroom
    # if current_wr == target_wr:
    #     logging.warning(f"Current workroom matches target: {current_wr} = {target_wr}")
    #     sys.exit(0)
        
    outputs = get_outputs()
    cmds = []
    
    # For each monitor, calculate which workspace it SHOULD have
    for i, output in enumerate(outputs):
        logging.debug(f"Outputs: id {i}, name {output['name']}")
        # Mon 1 gets Project01, Mon 2 gets Project02...
        # Project 1 -> 101, 102
        ws_num = compute_ws_num(target_wr, i)
        
        # 1. Map the workspace to this specific monitor (Sticky association)
        cmds.append(f"workspace {ws_num} output '{output['name']}'")
        # 2. Actually switch to it
        cmds.append(f"workspace {ws_num}")
    
    # Run all commands at once for a smooth "Global Switch"
    swaymsg("; ".join(cmds))

def move_between_workrooms(target_wr: int) -> None:
    outputs = get_outputs()

    # Get output Name and Index for workspace computation
    for i, output in enumerate(outputs):
        if output["focused"]:
            output_index = i
            output_name = output["name"]
            break

    target_ws_num = compute_ws_num(target_wr, i)

    cmds = []
    # Map the workspace to the output BEFORE moving. 
    # If the target workspace doesn't exist yet, Sway would spawn it on the 
    # currently focused screen by default. If container exists this has no effect.
    cmds.append(f"workspace {target_ws_num} output '{output_name}'")
    # Move the focused container
    cmds.append(f"move container to workspace {target_ws_num}")
    
    swaymsg("; ".join(cmds))

if __name__ == "__main__":

    if len(sys.argv) > 4:
        logging.error("Usage: workroom [current_workroom: number] [switch|move: string] [target_workroom: number]")
        sys.exit(1)

    try:
        current_wr = int(sys.argv[1])
        action = sys.argv[2]
        target_wr = int(sys.argv[3])
    except ValueError as e:
        logging.error(f"{e} - Args 1 and 3 need to be of type int: {current_wr}, {target_wr}")
        sys.exit(1)
    except Exception as e:
        logging.error(f"Error parsing args - {e}: {current_wr}, {action}, {target_wr}")
        sys.exit(1)

    if action == "switch":
        switch_project(current_wr, target_wr)
    elif action == "move":
        move_between_workrooms(target_wr)
