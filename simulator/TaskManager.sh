#!/bin/bash

TASK_DIR="./tasks"
LOG_DIR="./logs"
HISTORY_DIR="./history"

mkdir -p "$TASK_DIR" "$LOG_DIR" "$HISTORY_DIR"

send_notification() {
    echo "[Notification] Task $1: $2"
}

# Prompted task addition
add_task_prompt() {
    echo "Enter Task Name:"
    read task_name
    echo "Enter Full Path of Script:"
    read script_path

    [[ ! -f "$script_path" ]] && { echo "Script not found!"; exit 1; }

    echo "Enter Task Type (Manual/Scheduled):"
    read task_type

    cron_expr=""
    if [[ "$task_type" == "Scheduled" ]]; then
        echo "Enter Cron Expression (e.g. */5 * * * *):"
        read cron_expr
    fi

    echo "Enter Email for Notifications (optional):"
    read notify_email

    task_file="$TASK_DIR/$task_name.meta"
    [[ -f "$task_file" ]] && { echo "Task already exists!"; exit 1; }

    cat <<EOF > "$task_file"
TASK_NAME=$task_name
SCRIPT_PATH=$script_path
TASK_TYPE=$task_type
CRON_EXPR=$cron_expr
NOTIFY_EMAIL=$notify_email
EOF

    if [[ "$task_type" == "Scheduled" ]]; then
        (crontab -l 2>/dev/null; echo "$cron_expr bash $(realpath $0) -e $task_name") | crontab -
    fi

    echo "✅ Task [$task_name] registered."
}

execute_task() {
    task_name=$1
    task_file="$TASK_DIR/$task_name.meta"
    [[ ! -f "$task_file" ]] && { echo "❌ Task not found."; exit 1; }

    source "$task_file"
    timestamp=$(date '+%Y%m%d-%H%M%S')
    log_file="$LOG_DIR/${task_name}_${timestamp}.log"
    history_file="$HISTORY_DIR/${task_name}.history"

    echo "Task Execution [$timestamp]" >> "$history_file"
    echo "Start: $(date)" >> "$history_file"
    start_time=$(date +%s)

    bash "$SCRIPT_PATH" &> "$log_file"
    status=$?

    end_time=$(date +%s)
    duration=$((end_time - start_time))

    if [[ $status -eq 0 ]]; then
        echo "Status: Success" >> "$history_file"
        send_notification "$task_name" "Succeeded"
    else
        echo "Status: Failed" >> "$history_file"
        send_notification "$task_name" "Failed"
    fi

    echo "End: $(date)" >> "$history_file"
    echo "Duration: $duration sec" >> "$history_file"
    echo "------------------------" >> "$history_file"
}

list_tasks() {
    echo "📋 Task List:"
    for meta in "$TASK_DIR"/*.meta; do
        source "$meta"
        echo "- $TASK_NAME ($TASK_TYPE)"
    done
}

list_folder_scripts() {
    echo "📂 Scripts found under folders:"
    find . -type f -name "*.sh" ! -path "./logs/*" ! -path "./TaskManager.sh" | while read script; do
        echo "- $script"
    done
}

delete_task() {
    task_name=$1
    task_file="$TASK_DIR/$task_name.meta"
    [[ ! -f "$task_file" ]] && { echo "❌ Task not found."; exit 1; }

    rm -f "$task_file"
    crontab -l | grep -v "$task_name" | crontab -
    echo "🗑️ Task [$task_name] deleted."
}

task_history() {
    task_name=$1
    history_file="$HISTORY_DIR/${task_name}.history"
    [[ -f "$history_file" ]] && cat "$history_file" || echo "No history."
}

task_logs() {
    task_name=$1
    echo "📁 Available logs for [$task_name]:"

    logs=$(find "$LOG_DIR" -type f -name "${task_name}_*.log" | sort)

    if [[ -z "$logs" ]]; then
        echo "No logs found."
        return
    fi

    echo "$logs"

    echo
    echo "📜 Showing the latest log content:"
    latest_log=$(echo "$logs" | tail -n 1)
    echo "➡️  $latest_log"
    echo "--------------------------"
    cat "$latest_log"
    echo "--------------------------"
}



usage() {
    cat <<EOF
Usage:
  ./TaskManager.sh -a              Add task interactively
  ./TaskManager.sh -l              List registered tasks
  ./TaskManager.sh -s              Show all .sh scripts under folders
  ./TaskManager.sh -e <task_name>  Execute task
  ./TaskManager.sh -d <task_name>  Delete task
  ./TaskManager.sh -h <task_name>  Show task history
  ./TaskManager.sh -g <task_name>  Show logs for task
EOF
}

case "$1" in
    -a) add_task_prompt ;;
    -l) list_tasks ;;
    -s) list_folder_scripts ;;
    -e) execute_task "$2" ;;
    -d) delete_task "$2" ;;
    -h) task_history "$2" ;;
    -g) task_logs "$2" ;;
    *) usage ;;
esac

