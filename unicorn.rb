# Set the working application directory
# working_directory "/path/to/your/app"
working_directory "/var/www/fll.presidentbeef.com/"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "/var/www/fll.presidentbeef.com/pids/unicorn.pid"

# Path to logs
# stderr_path "/path/to/logs/unicorn.log"
# stdout_path "/path/to/logs/unicorn.log"
stderr_path "/var/www/fll.presidentbeef.com/logs/unicorn.log"
stdout_path "/var/www/fll.presidentbeef.com/logs/unicorn.log"

# Unicorn socket
listen "/tmp/unicorn.fllp.sock"

# Number of processes
worker_processes 4

# Time-out
timeout 30
