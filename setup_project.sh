#!/bin/bash


#PYTHON3 VERIFICATION
#!/bin/bash

version_check=$(python3 --version 2>&1 )

if [ -n "$version_check" ]; then
        echo "python3 is present. Version: $version_check"
else
        echo "python3 is missing"
        while true; do
                read -p "Do you want to install python3? (yes/no): " install
                if [ "$install" = "yes" ]; then
                        sudo apt update && sudo apt install python3
                        version_again=$(python3 --version 2>&1)
                        echo "Python3 sucessfully installed. Version: $version_again"
                        break
                elif [ "$install" = "no" ]; then
                        echo "Python3 not installed. Continuing ..."
                        break
                else
                        echo "Invalid response. Please enter yes or no"
                fi
        done
fi


echo ""
while true; do
	read -p "Give an input for directory creation: " u_input

	# Check if user provided input
    if [ -n "$u_input" ]; then
	    break
    else
	    echo " Name cannot be empty. Please enter a string"
    fi
done

sigint() {
	echo ""
	echo "Script execution is interrupted. The progress will be archived"
	if [ -d  "$parent_dir" ]; then
		tar czf "attendance_tracker_${u_input}_archive.tgz" "$parent_dir"
		rm -rf "$parent_dir"
	fi
	echo "progress removed and archived"
	exit 1
}
trap 'sigint' SIGINT


# Create parent directory
parent_dir="attendance_tracker_$u_input"
mkdir -p "$parent_dir"

# Create main logic file

cat > "$parent_dir/attendance_checker.py" << EOF 
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)

    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']

        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])

            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100

            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

# Create Helpers directory and files
mkdir -p "$parent_dir/Helpers"
cat > "$parent_dir/Helpers/assets.csv" << EOF

Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

cat > "$parent_dir/Helpers/config.json" << EOF
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

while true; do
	echo ""
        echo "Update config.json?
        A. Warning threshold
        B. Failure threshold
        C. Both
	D. None" 

	read -p "Enter your choice: " choice

        if [ "${choice,,}" = "a" ]; then
                read -p "Enter new warning threshold: " w_threshold
                sed -i "s/\"warning\": [0-9]*/\"warning\": $w_threshold/" "$parent_dir/Helpers/config.json"
		echo ""
                echo "Warning threshold replaced with $w_threshold"
                break
        elif [ "${choice,,}" = "b" ]; then
                read -p "Enter new failure threshold: " f_threshold
                sed -i "s/\"failure\": [0-9]*/\"failure\": $f_threshold/" "$parent_dir/Helpers/config.json"
		echo ""
                echo "Failure threshold replaced with $f_threshold"
                break
	elif [ "${choice,,}" = "c" ]; then
		read -p "Enter new warning threshold: " w_threshold
		read -p "Enter new failure threshold: " f_threshold
                sed -i "s/\"warning\": [0-9]*/\"warning\": $w_threshold/" "$parent_dir/Helpers/config.json"
		sed -i "s/\"failure\": [0-9]*/\"failure\": $f_threshold/" "$parent_dir/Helpers/config.json"
		echo ""
		echo "Failure and warning thresholds replaced with $f_threshold and $w_threshold"
                break
        elif [ "${choice,,}" = "d" ]; then
                echo "No changes made to the thresholds"
                break
        else
                echo "Invalid input. Please enter A, B, C, or D"
	fi
done


# Create reports directory and file
mkdir -p "$parent_dir/reports"
cat > "$parent_dir/reports/reports.log" << EOF
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF

echo ""
echo "Directory structure created under $parent_dir"

tree ./$parent_dir
