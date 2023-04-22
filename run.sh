#!/bin/bash
echo "processing-opencv_v1"

# Function to terminate child process on exit
on_exit() {
	echo "Exiting..."
	# Kill the Python process beofre exiting
	kill $python_pid
	# Kill the tmux session
	tmux kill-session -t particles-session
	exit
}

# Set a trap for the SIGTERM signal (sent when application is closed)
trap on_exit EXIT

# Start the main python program and the processing4 app
python "$(dirname "$0")/main.py" &
python_pid=$!

sleep 5

# Start a new tmux session and run Particles in it
tmux new-session -d -s particles-session "./Particles/linux-aarch64/Particles"
particles_pid=$!

# Give app time to start up
sleep 10

# Attach to the tmux session to monitor the application
tmux attach-session -t particles-session

# Wait for the application to finish
wait $particles_pid

