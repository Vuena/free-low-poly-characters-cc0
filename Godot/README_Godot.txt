Godot 4 sample project.
Open this folder in Godot 4.2+ (Project Manager > Import > project.godot) and press F5.
Keys: Up/Down cycle through all clips in the file, 1-9 and 0 jump to the first ten clips, Left/Right switch character.
The scene is built from code in demo.gd. To use a character in your own project, copy its .glb into your project:
the imported scene contains the Armature (22 Mixamo-named bones), the 'Body' mesh and an AnimationPlayer with the clips (10 in this download).
glTF clips import without looping; set Loop Mode = Linear for the looping clips (demo.gd has the list and shows how).
