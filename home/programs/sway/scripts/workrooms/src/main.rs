use simplelog::*;
use std::env;
use std::fs::OpenOptions;
use swayipc::{Connection, Output};

const MULTIPLIER: i32 = 10;
const LOG_FILE: &str = "/tmp/workroom.log";

fn show_usage() {
    println!("Usage:");
    println!("  workroom switch <current_wr> <target_wr>");
    println!("  workroom move_container <target_wr>");
    println!("  workroom move_workspace <target_output_id(1-9)>");
    println!("  workroom swap <true|false>");
    std::process::exit(1);
}

fn compute_ws_num(workroom: i32, output_index: usize) -> i32 {
    // Returns the workspace number starting with 11 to keep keybinds left sided
    (workroom * MULTIPLIER) + (output_index as i32 + 1)
}

fn execute_sway_cmd(conn: &mut Connection, cmd: String) {
    log::debug!("Executing: swaymsg {}", cmd);
    if let Err(e) = conn.run_command(&cmd) {
        log::error!("Sway command failed: {}", e);
    }
}

fn get_active_outputs(conn: &mut Connection) -> Vec<Output> {
    // Get all outputs natively via IPC
    let mut outputs = conn.get_outputs().expect("Failed to get Sway outputs");

    // Filter for active outputs
    outputs.retain(|o| o.active);
    
    // Sort them by x position (Left to Right)
    outputs.sort_by_key(|o| o.rect.x);
    
    log::debug!("Number of active outputs: {}", outputs.len());
    outputs
}

fn switch_workroom(conn: &mut Connection, target_wr: i32) {
    let outputs = get_active_outputs(conn);
    let mut cmds = Vec::new();

    // Maps the workspaces to the outputs for the target workroom
    // Then switches to the mapped workspace
    for (i, output) in outputs.iter().enumerate() {
        log::debug!("Outputs: id {}, name {}", i, output.name);
        let ws_num = compute_ws_num(target_wr, i);

        cmds.push(format!("workspace {} output '{}'", ws_num, output.name));
        cmds.push(format!("workspace {}", ws_num));
    }

    execute_sway_cmd(conn, cmds.join("; "));
}

fn move_between_workrooms(conn: &mut Connection, target_wr: i32) {
    let outputs = get_active_outputs(conn);

    let mut output_index = 0;
    let mut output_name = String::new();

    for (i, output) in outputs.iter().enumerate() {
        if output.focused {
            output_index = i;
            output_name = output.name.clone();
            break;
        }
    }

    if output_name.is_empty() {
        log::error!("Could not find a focused output.");
        std::process::exit(1);
    }

    let target_ws_num = compute_ws_num(target_wr, output_index);

    // Binding ws to output, so moving to empty ws doesn't break workroom-output mapping
    let mut cmds = Vec::new();
    cmds.push(format!("workspace {} output '{}'", target_ws_num, output_name));
    cmds.push(format!("move container to workspace {}", target_ws_num));

    execute_sway_cmd(conn, cmds.join("; "));
}

fn swap_next_previous (conn: &mut Connection, swap_next: bool) {
    let outputs = get_active_outputs(conn);
    let len = outputs.len();

// Find the focused index or abort
    let focused_idx = outputs
        .iter()
        .position(|out| out.focused)
        .unwrap_or_else(|| {
            log::warn!("No focused output found in the current state. Exiting.");
            std::process::exit(1); 
        });

    // Find the index of the swap partner
    let partner_idx = if swap_next {
        (focused_idx + 1) % len
    } else {
        (focused_idx + len - 1) % len
    };

    let current_ws = outputs[focused_idx].current_workspace.as_ref().unwrap();
    let partner_ws = outputs[partner_idx].current_workspace.as_ref().unwrap();

    log::debug!("Swapping workspaces {} and {}", current_ws, partner_ws); 

    let mut cmds = Vec::new();
    cmds.push(format!("move workspace to output {}", outputs[partner_idx].name));
    cmds.push(format!("workspace {}", partner_ws));
    cmds.push(format!("move workspace to output {}", outputs[focused_idx].name));

    execute_sway_cmd(conn, cmds.join(";"))
}

fn move_ws_to_output(conn: &mut Connection, target_output_id: usize) {
    let outputs = get_active_outputs(conn);

    let Some(output) = outputs.get(target_output_id - 1) else {
        log::warn!("Output index {} is out of bounds.", target_output_id);
        std::process::exit(0);
    };

    execute_sway_cmd(conn, format!("move workspace output {}", output.name))
}

fn main() {
    let log_file = OpenOptions::new()
        .create(true)
        .append(true)
        .open(LOG_FILE)
        .unwrap();

    let _ = WriteLogger::init(
        LevelFilter::Error,
        ConfigBuilder::new()
            .set_time_format_custom(format_description!("[year]-[month]-[day] [hour]:[minute]:[second],[subsecond digits:3]"))
            .build(),
        log_file,
    );

    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        show_usage();
    }

    let mut conn = Connection::new().expect("Could not connect to Sway IPC");
    let action = args[1].as_str();

    match action {
        "switch" if args.len() == 3 => {
            let target_wr: i32 = args[2].parse().expect("Target workroom must be a number");
            switch_workroom(&mut conn, target_wr);
        }
        "move_container" if args.len() == 3 => {
            let target_wr: i32 = args[2].parse().expect("Target workroom must be a number");
            move_between_workrooms(&mut conn, target_wr);
        }
        "move_workspace" if args.len() == 3 => {
            let target_output_id: usize = args[2].parse().expect("Target output id must be a positiv number");
            move_ws_to_output(&mut conn, target_output_id);
        }
        "swap" if args.len() == 3 => {
            let is_next: bool = args[2].parse().expect("Swap requires 'true' or 'false'");
            swap_next_previous(&mut conn, is_next);
        }
        _ => {
            log::error!("Invalid arguments or action: {:?}", args);
            show_usage();
        }
    }
}
