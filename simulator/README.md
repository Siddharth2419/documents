# 🧠 TaskManager.sh

`TaskManager.sh` is a Bash-based utility designed to manage manual and scheduled task execution using a command-line interface. It supports cron-based scheduling, execution logging, task history tracking, and basic notifications — simulating Jenkins-style automation without the overhead.

---

## 📁 Folder Structure

project-root/
├── TaskManager.sh # Main script
├── tasks/ # Task metadata files
├── logs/ # Output logs of executions
├── history/ # Execution history per task
├── db/
│ ├── backup.sh
│ └── cleanup.sh
├── functions/
│ ├── deploy.sh
│ └── validate.sh
├── test/
│ ├── unit-test.sh
│ └── integration-test.sh

yaml
Copy
Edit

---

## ⚙️ Features

- 🖥️ Register manual or scheduled tasks interactively (no JSON needed)
- ⏱️ Cron-based task execution
- 🗂️ Auto-discovery of scripts across folders
- 📋 List, run, and delete tasks via command line
- 📜 Task history tracking (start/end time, duration, status)
- 📁 Log output for each execution
- ✉️ Extendable email notification stub

---

## 🚀 Getting Started

### Clone the Repo

```bash
git clone https://github.com/your-username/taskmanager.git
cd taskmanager
chmod +x TaskManager.sh
🧪 Usage Guide
➕ Add a New Task
bash
Copy
Edit
./TaskManager.sh -a
You’ll be prompted for:

Task name

Full script path (e.g., functions/deploy.sh)

Task type (Manual or Scheduled)

Cron expression (if Scheduled)

Optional email address

📋 List All Registered Tasks
bash
Copy
Edit
./TaskManager.sh -l
🔍 Discover Scripts Across Folders
bash
Copy
Edit
./TaskManager.sh -s
Finds .sh scripts in subfolders like db/, functions/, and test/.

▶️ Execute a Task
bash
Copy
Edit
./TaskManager.sh -e <task_name>
Runs the task script and stores:

A log in logs/

Execution details in history/

📜 View Execution History
bash
Copy
Edit
./TaskManager.sh -h <task_name>
Displays:

Execution timestamps

Duration

Status (Success or Failure)

📁 View Logs for a Task
bash
Copy
Edit
./TaskManager.sh -g <task_name>
Lists log files for the given task

Displays the most recent log file content directly in the terminal

🗑️ Delete a Task
bash
Copy
Edit
./TaskManager.sh -d <task_name>
Deletes:

Task metadata file

Associated cronjob (if any)

🧩 Example Workflow
bash
Copy
Edit
./TaskManager.sh -a              # Register a new task
./TaskManager.sh -e deploy-task # Execute the task
./TaskManager.sh -g deploy-task # View the latest log
./TaskManager.sh -h deploy-task # View task history
./TaskManager.sh -d deploy-task # Delete the task
