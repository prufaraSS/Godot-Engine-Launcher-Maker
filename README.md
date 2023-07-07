# Godot Engine Launcher Maker
Makes much easier and faster to create launcher for anything you need.
Release v2.0 on Godot Engine v4.1.stable.official [970459615]

## Major Update 2.0
Project has been rewritten from scratch in Godot Engine v4.1 with new system of node saving, allowing you to easily tag which nodes must be saved.
New Handle class allows to determine how each Godot Engine classes (or even your own!) should be treated to get or set information from them.
For start, you can just modify the 'main' scene, but if you want to create a new one, you must follow these steps:
1. Set the root of scene to LauncherMain class.
2. Set all properties in root node so it can execute the application.
3. Tag every node you need to save with applying 'keep' group to.
4. Add button with these signal connections to root node: Save, Proceed, Quit
5. (Add a button with "autosave" group)
6. (Add a button with "autoproceed" group)
7. Make sure every node is functioning fine, if not, check out debugger for errors.
