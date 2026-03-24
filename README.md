# debug-ti-with-jlink

Things to have installed on a (windows) host:
- [usbipd-win](https://github.com/dorssel/usbipd-win)
- latest segger version [(this container used V928)](https://www.segger.com/downloads/jlink/JLink_Windows_V928_x86_64.exe)
- docker with WSL2 engine
- Visual Studio Code
  - Remote Development extension pack: ms-vscode-remote.vscode-remote-extensionpack

Ensure a SEGGER Jlink is connected, then bind and attach it using usbipd:
- `$ usbipd list`
- `$ usbipd bind --hardware-id <id>`
- `$ usbipd attach --wsl --hardware-id <id>`

Once a JLink has been attached start Visual Studio Code. If it was already running it must be restarted.
Within Visual Studio Code use `ctrl+shift+p` to open the Command Pallet. Then use/type `Dev Containers: Clone Repository in Container Volume...`

This will prompt to enter a remote (GitHub) repository, search for `this` specific repository and hit enter.

This will then start a bootstrap container, clone the repository and build the contained Dockerfile. This might take a minute or two. Depending on the available RAM/CPU and internet connection.

ℹ️ Note! The container runs in priveleged mode. That means it has access to the hosts devices. The base container is not a standard ubuntu container, but our custom amp-devcontainer-cpp flavour. If you need to know what that does its available here: [amp-devcontainer](https://github.com/philips-software/amp-devcontainer) 
