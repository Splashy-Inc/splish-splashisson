# This file is meant to automate the upload of a Splashy Inc. Godot project to itch.io

import subprocess
import shutil
from pathlib import Path
import sys

godot_project_path = ".."
export_directory = "Exports/WebFiles"
export_file_name = "index.html"
export_profile = "Web"
export_path = godot_project_path + "/" + export_directory


compressed_file_name = "web"
compressed_file_type = "zip"


itch_account = ""
itch_game = ""

itch_account = input("Enter the itch.io account to upload to: ")
itch_game = input("Enter the game on the itch.io account to update with the upload: ")

if itch_account == "":
    print("Blank itch.io account entered, please run this script again.")
    sys.exit(1)
if itch_game == "":
    print("Blank itch.io game entered, please run this script again.")
    sys.exit(1)

itch_upload_path = itch_account + "/" + itch_game + ":" + export_profile


Path(export_path).mkdir(parents=True, exist_ok=True)

print("Attempting to export ", export_profile, " from ", godot_project_path, " to ", export_path, " as ", export_file_name)

godot_export_process = subprocess.run(["godot", "--path", godot_project_path, "--export-release", export_profile, export_directory + "/" + export_file_name], shell=True, capture_output=True)

if godot_export_process.returncode == 0:
    print("Successfully exported ", export_profile, " from ", godot_project_path, " to ", export_path, " as ", export_file_name)
   
    print("Attempting to compress ", export_path, " to ", "./" + compressed_file_name + "." + compressed_file_type)

    compressed_file_path = shutil.make_archive(export_path + "/../" + compressed_file_name, compressed_file_type, export_path)

    print("Directory compressed to ", compressed_file_path)

    print("Attempting to upload ", compressed_file_path, " to ", itch_upload_path)

    itch_upload_process = subprocess.run(["butler", "push", compressed_file_path, itch_upload_path], shell=True, capture_output=True)

    if itch_upload_process.returncode == 0:
        print("Successfully uploaded ", compressed_file_path, " to ", itch_upload_path)
    else:
        print("Issue uploading ", compressed_file_path, " to ", itch_upload_path)
        print(itch_upload_process.stderr)
else:
    print("Issue exporting ", export_profile, " from ", godot_project_path)
    print(godot_export_process.stderr)
