#!/bin/bash
# /usr/local/bin/pbs-launch-gui
#
# This script is launched by an interactive PBS job. It starts a VNC server
# within the job's allocation and provides connection instructions,
# now including noVNC for web-based access.

# --- VNC Server Configuration ---
VNC_GEOMETRY="1920x1080"
VNC_DEPTH="24"
VNC_SESSION="openbox-session"
# The -localhost flag is a critical security measure for VNC server.
VNC_ARGS="-localhost -geometry ${VNC_GEOMETRY} -depth ${VNC_DEPTH} -xstartup ${VNC_SESSION}"

# --- noVNC Configuration ---
NOVNC_DIR="/etc/ssl/noVNC/noVNC"
NOVNC_ZIP_URL="https://github.com/novnc/noVNC/archive/refs/tags/v1.6.0.zip"
NOVNC_ZIP_FILE="v1.6.0.zip"
NOVNC_EXTRACTED_FOLDER="noVNC-1.6.0"
# NOVNC_PROXY_PORT will be calculated based on VNC_DISPLAY

# --- Job Cleanup ---
# Function to kill the VNC server and noVNC proxy when the job ends
cleanup() {
    # Check if VNC_DISPLAY is set before trying to kill VNC server
    if [ ! -z "${VNC_DISPLAY}" ]; then
        echo "[INFO] PBS job terminated. Killing VNC server on display ${VNC_DISPLAY}."
        vncserver -kill ${VNC_DISPLAY}
    else
        echo "[WARN] VNC display not found, unable to kill VNC server automatically."
        echo "[ACTION] Please manually check for and kill any lingering VNC processes."
    fi

    # Kill noVNC proxy process
    # Use the calculated NOVNC_PROXY_PORT for cleanup
    if [ ! -z "${NOVNC_PROXY_PORT}" ]; then
        echo "[INFO] Killing noVNC proxy on port ${NOVNC_PROXY_PORT}."
        # Find processes listening on the noVNC proxy port and kill them
        lsof -t -i TCP:${NOVNC_PROXY_PORT} | xargs kill -9 2>/dev/null || true
    fi
}
# Trap the EXIT signal of the script (sent when the PBS job ends)
trap cleanup EXIT

# --- VNC Password Check ---
VNC_PASSWD_FILE="${HOME}/.vnc/passwd"
if [ ! -f "${VNC_PASSWD_FILE}" ]; then
    echo "------------------------------------------------------------------"
    echo "[IMPORTANT] VNC password file not found!"
    echo "            You need to set a password for your VNC server."
    echo "            Please run the following command in a new terminal:"
    echo ""
    echo "            vncpasswd"
    echo ""
    echo "            After setting the password, please re-submit your PBS job."
    echo "------------------------------------------------------------------"
    exit 1 # Exit with an error code to indicate failure
fi
# Ensure the password file has correct permissions
chmod 600 "${VNC_PASSWD_FILE}"
echo "[INFO] VNC password file found and permissions set."


# --- Check and Download/Extract noVNC ---
echo "[INFO] Checking for noVNC installation..."
if [ ! -d "${NOVNC_DIR}" ]; then
    echo "[INFO] noVNC directory '${NOVNC_DIR}' not found. Downloading and extracting..."
    # Download noVNC
    if command -v wget &> /dev/null; then
        wget -q ${NOVNC_ZIP_URL} -O ${NOVNC_ZIP_FILE}
    elif command -v curl &> /dev/null; then
        curl -sL ${NOVNC_ZIP_URL} -o ${NOVNC_ZIP_FILE}
    else
        echo "[ERROR] Neither wget nor curl found. Cannot download noVNC. Please install one."
        exit 1
    fi

    if [ ! -f "${NOVNC_ZIP_FILE}" ]; then
        echo "[ERROR] Failed to download noVNC zip file."
        exit 1
    fi

    # Extract noVNC
    if command -v unzip &> /dev/null; then
        unzip -q ${NOVNC_ZIP_FILE}
        # Rename the extracted folder to 'noVNC'
        if [ -d "${NOVNC_EXTRACTED_FOLDER}" ]; then
            mv ${NOVNC_EXTRACTED_FOLDER} ${NOVNC_DIR}
            echo "[INFO] noVNC extracted and renamed to '${NOVNC_DIR}'."
        else
            echo "[ERROR] Extracted folder '${NOVNC_EXTRACTED_FOLDER}' not found. Extraction might have failed."
            exit 1
        fi
    else
        echo "[ERROR] unzip command not found. Cannot extract noVNC. Please install unzip."
        exit 1
    fi

    # Clean up the downloaded zip file
    rm -f ${NOVNC_ZIP_FILE}
else
    echo "[INFO] noVNC directory '${NOVNC_DIR}' already exists."
fi

# Ensure novnc_proxy is executable
if [ -f "${NOVNC_DIR}/utils/novnc_proxy" ]; then
    if [ -x "${NOVNC_DIR}/utils/novnc_proxy" ]; then
        echo "The noVNC proxy script is a file and is executable."
    else
        echo "[ERROR] The noVNC proxy script exists but is not executable. Please check its permissions."
        exit 1
    fi
else
    echo "[ERROR] noVNC proxy script not found at ${NOVNC_DIR}/utils/novnc_proxy."
    exit 1
fi

# --- Start VNC Server ---
echo "[INFO] Starting VNC server within PBS allocation..."
# Start the server and capture its output to find the display number
vnc_output=$(vncserver ${VNC_ARGS} 2>&1)

# ADDED DEBUGGING
echo "--- VNC Server Raw Output ---"
echo "${vnc_output}"
echo "-----------------------------"

# Use a new method to find the VNC display number
# This greps for "for display :<number>" and extracts the last part
VNC_DISPLAY=$(echo "${vnc_output}" | grep "for display" | awk '{print $NF}' | sed 's/\.$//')

# Check if the server started successfully
if [ -z "${VNC_DISPLAY}" ]; then
    echo "[ERROR] Failed to start VNC server. Output was:"
    echo "${vnc_output}"
    exit 1
fi

# ADD THIS DEBUGGING LINE
echo "[DEBUG] VNC_DISPLAY is: ${VNC_DISPLAY}"
echo "[DEBUG] Value for arithmetic expansion is: ${VNC_DISPLAY#:}"

VNC_PORT=$(echo ${VNC_DISPLAY#:} | awk '{print 5900 + $1}')
NODE_HOSTNAME=$(hostname -f)
NODE_IP=$(hostname -I | awk '{print $1}') # Get the IP address of the host
NOVNC_PROXY_PORT=$(echo ${VNC_DISPLAY#:} | awk '{print 6080 + $1}') # noVNC proxy port based on VNC display
SSL_CERT="/etc/ssl/noVNC/self.pem" #change accordingly

# --- Start noVNC Proxy ---
echo "[INFO] Starting noVNC proxy on port ${NOVNC_PROXY_PORT}..."
# Run noVNC proxy in the background, redirecting output to a log file
nohup "${NOVNC_DIR}/utils/novnc_proxy" --vnc "localhost:${VNC_PORT}" --listen "${NOVNC_PROXY_PORT}" --heartbeat 10 --timeout 240 --cert "${SSL_CERT}" > novnc_proxy.log 2>&1 &
NOVNC_PID=$! # Capture the PID of the noVNC proxy process
echo "[INFO] noVNC proxy started with PID: ${NOVNC_PID}"
sleep 2 # Give noVNC proxy a moment to start

# --- Print Connection Instructions for the User ---
echo "------------------------------------------------------------------"
echo "         PBS Graphical Session is READY"
echo "------------------------------------------------------------------"
echo "[INFO] VNC Server started on node: ${NODE_IP}"
echo "[INFO] VNC Display is:             ${VNC_DISPLAY}"
echo "[INFO] VNC Port is:                ${VNC_PORT}"
echo "[INFO] Web browser port is:        ${NOVNC_PROXY_PORT}"
echo ""
echo "[ACTION] Connect via VNC Client (e.g., TigerVNC Viewer):"
echo "         1. Use the above mentioned ip address and port, together with your username and the VNC password you set."
echo ""
echo "------------------------------------------------------------------"
echo "[ACTION] To connect via Web Browser (noVNC):"
echo "         1. Navigate to https://${NODE_IP}:${NOVNC_PROXY_PORT}/vnc.html"
echo "         2. Log in using your VNC password."
echo ""
echo "[IMPORTANT] This terminal is now managing your PBS job. To end your"
echo "            session, close your VNC window and press Ctrl+C here"
echo "            or run 'qdel ${PBS_JOBID}'."
echo "------------------------------------------------------------------"

# --- Wait for Job to End ---
# Keep the script running. The 'trap' will handle cleanup when the job is killed.
wait ${NOVNC_PID} # Wait for the noVNC proxy process to finish, or until the script is terminated
