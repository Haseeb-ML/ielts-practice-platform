import os
import glob

def merge_mp3_files(folder_path, output_filename="merged_audio.mp3"):
    # Find all mp3 files in the folder
    search_pattern = os.path.join(folder_path, "*.mp3")
    mp3_files = glob.glob(search_pattern)
    
    # Exclude the output file if it's already there
    mp3_files = [f for f in mp3_files if not f.endswith(output_filename)]
    
    if not mp3_files:
        print(f"Koi MP3 file nahi mili is folder mein: {folder_path}")
        return

    # Sort files alphabetically (e.g. part1.mp3, part2.mp3 will be in order)
    mp3_files.sort()
    
    print(f"In {len(mp3_files)} files ko merge kiya ja raha hai:")
    for f in mp3_files:
        print(f" - {os.path.basename(f)}")
        
    output_path = os.path.join(folder_path, output_filename)
    
    # Open the output file in write-binary mode
    with open(output_path, 'wb') as outfile:
        for mp3_file in mp3_files:
            # Read each input file in read-binary mode and write to output
            with open(mp3_file, 'rb') as infile:
                outfile.write(infile.read())
                
    print(f"\nZabardast! Files successfully merge ho gayi hain.\nNayi file yahan save hui hai: {output_path}")

if __name__ == "__main__":
    print("--- MP3 Audio Merger ---")
    print("Apni 4 audio files ko ek folder mein rakhein.")
    folder = input("Us folder ka path yahan paste karein: ").strip()
    
    # Remove quotes if user pasted path with quotes
    if folder.startswith('"') and folder.endswith('"'):
        folder = folder[1:-1]
        
    if os.path.isdir(folder):
        merge_mp3_files(folder)
    else:
        print("Error: Yeh folder path theek nahi hai.")
