import os

# Directory with files
folder = "."

for count, filename in enumerate(os.listdir(folder)):
    if filename.endswith(".txt"):
        new_name = f"file_{count}.txt"
        os.rename(filename, new_name)
        print(f"Renamed {filename}  {new_name}")
