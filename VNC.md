# TigerVNC and noVNC Installation on Debian 12

This README provides instructions for installing and configuring TigerVNC and noVNC on Debian 12. This setup allows for remote graphical desktop access through a web browser.

**NOTE:** This is a work in progress and may be subject to changes.

## Prerequisites

  - A fresh installation of Debian 12.
  - `sudo` or `root` access.

## Installation Steps

### 1\. Install Required Packages

First, update the package list and install the necessary software:

```bash
sudo apt update
sudo apt install -y tigervnc-standalone-server openbox python3-numpy
```

  - **`tigervnc-standalone-server`**: The core VNC server software.
  - **`openbox`**: A lightweight window manager. We use this to provide a graphical environment within the VNC session.

### 2\. Configure Openbox

We need to make some tweaks to Openbox to make it more usable in our VNC session.

#### Tweak `menu.xml`

Edit the Openbox menu file to include applications that the users should be able to launch. This file is located at `/etc/xdg/openbox/menu.xml`. You can use a text editor like `nano`:

```bash
nano /etc/xdg/openbox/menu.xml
```

For example, to add an entry for `xterm`, you would add a block like this within the `<menu>` tag:

```xml
<item label="Terminal">
    <action name="Execute">
        <execute>xterm</execute>
    </action>
</item>
```

#### Configure Autostart

We will configure Openbox to automatically set a wallpaper when it starts. Edit the autostart file:

```bash
sudo nano /etc/xdg/openbox/autostart
```

Add the following line to the end of the file. This will download a wallpaper from the specified URL and set it as the desktop background:

```bash
# Set a wallpaper to a solid color
xsetroot -solid "#265792" &
```

The `&` at the end is crucial as it runs the command in the background, allowing the Openbox startup process to continue. The wallpaper can also be downloaded just once then referenced by nitrogen.

### 3\. Generate an SSL Certificate for noVNC

noVNC requires an SSL certificate for secure connections. We will create a self-signed certificate.

First, create a directory for the certificate and set the correct permissions:

```bash
sudo mkdir /etc/ssl/noVNC
sudo chmod 755 /etc/ssl/noVNC
cd /etc/ssl/noVNC
```

Now, generate the self-signed certificate. This command creates a certificate valid for 10 years and stores both the certificate and private key in a single file named `self.pem`:

```bash
sudo openssl req -new -x509 -days 3650 -nodes -out self.pem -keyout self.pem
```

You will be prompted to enter information for the certificate. You can enter any details you prefer, or simply press `Enter` to leave them blank.

### 4\. Launch VNC with a Script

A script can be used to manage the noVNC setup and launch the VNC server. This example leverages the script named `pbs-launch-gui.sh` that handles the noVNC download and server launch.

The script performs the following actions:

  - Download the noVNC source if it doesn't already exist.
  - Start a TigerVNC server on a specific display (e.g., `:1`).
  - Configure the VNC server to use Openbox as the desktop environment.
  - Prompt the user to set a VNC password using `vncpasswd` if one is not already set.
  - Launch the noVNC websocket proxy, which bridges the VNC server to the web browser.

The first time a user runs the script, they will be prompted to set a password for the VNC session. This password will be stored in `~/.vnc/passwd`.

To run the script:

```bash
# Ensure the script is executable
chmod +x pbs-launch-gui.sh

# Run the script
./pbs-launch-gui.sh
```

After the script runs, a VNC session should be accessible by navigating to the specified URL (usually `https://<your-server-ip>:6080`) in your web browser.

### 5\. Tweak the VNC permissions
```bash
chgrp -R users /etc/ssl/noVNC
chmod -R 750 /etc/ssl/noVNC
```

