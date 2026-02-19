# deploy_agent_hussaina3
  


PROJECT OVERVIEW

This project is a Bash automation script that generates a complete Python-based attendance tracking system. The solution automates directory creation, validates the system environment, allows configuration updates, and implements process management to ensure safe execution. It verifies that Python3 is installed, creates the required project structure, applies configurable attendance thresholds, and logs results. Additionally, it includes a signal-handling mechanism that archives and cleans up incomplete directories if the script is interrupted.

Running the Script

To execute the script:

Grant execute permission:

chmod +x script_name.sh


Run the script:

./script_name.sh


Provide a directory name when prompted.

During execution, the script will:

Verify python3 --version

Prompt installation if Python3 is missing

Create the required directory structure

Generate the Python logic file, configuration file, dataset, and reports directory

Allow threshold configuration updates

The script completes without requiring manual file setup.

Triggering the Archive Feature

The archive mechanism is activated if the script is interrupted during execution.

To trigger it:

Start running the script.

Press CTRL + C before completion.

When a SIGINT signal is detected, the script will:

Archive the partially created directory into a .tgz file.

Delete the incomplete folder.

Exit cleanly.
