import os
from docx import Document

# Load the DOCX file
doc = Document("/opinions/1182016 - 9162013.DOCX")

# Extract the content
content = []
for paragraph in doc.paragraphs:
    content.append(paragraph.text)
    
# Directory to save the output files
output_dir = "/court_text/"
os.makedirs(output_dir, exist_ok=True)

# Function to identify if a line is a heading
def is_heading(line, next_line):
    return bool(line) and "United States Court of Appeals" in next_line

# Split the content based on headings
cases = []
current_case = []
for i in range(len(content)):
    line = content[i]
    next_line = content[i+1] if i+1 < len(content) else ""
    if is_heading(line, next_line):
        if current_case:  # If there's content in the current case, save it
            cases.append(current_case)
            current_case = []
    current_case.append(line)
if current_case:  # Save the last case
    cases.append(current_case)

# Write each case to a separate .txt file
file_paths = []
for case in cases:
    heading = case[0].replace(" ", "_").replace(".", "").replace(",", "")  # Make the heading filename-friendly
    file_name = f"{heading}.txt"
    file_path = os.path.join(output_dir, file_name)
    with open(file_path, 'w') as file:
        file.write("\n".join(case))
    file_paths.append(file_path)

file_paths
