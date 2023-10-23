import os
import re
import csv
from dateutil.parser import parse

def extract_date_from_file(file_path):
    """Extract the 'date filed' from the text file."""
    with open(file_path, 'r', encoding='utf-8') as file:
        # Consider only the first 10 lines for efficiency
        for _ in range(10):
            line = file.readline()
            # Check for the pattern "Date Filed: <date>"
            match = re.search(r'([\w\s,]+), Filed', line)
            if match:
                return standardize_date(match.group(1))
    return None
def standardize_date(date_str):
    """Convert the date string into a standardized format"""
    try:
        #parse date
        date_obj = parse(date_str)
        #return date in YYYY-MM-DD format
        return date_obj.strftime('%Y-%m-%d')
    except:
        #if parsing fails, returns original date structure
        return date_str
def main(directory1, directory2, output_csv_path):
    """Extract dates and write to CSV."""

    os.makedirs(os.path.dirname(output_csv_path), exist_ok=True)


    with open(output_csv_path, 'w', newline='', encoding='utf-8') as csvfile:
        csv_writer = csv.writer(csvfile)
        csv_writer.writerow(['Title', 'Date Filed'])

        for directory in [directory1, directory2]:
            for file_name in os.listdir(directory):
                file_path = os.path.join(directory, file_name)
                date_filed = extract_date_from_file(file_path)
                if date_filed:
                    csv_writer.writerow([file_path, date_filed])

if __name__ == "__main__":
    dir1 = 'c:/Users/conno/OneDrive/Documents/GitHub/Honors-Thesis-ADA-project/data/input/appellate'
    dir2 = 'c:/Users/conno/OneDrive/Documents/GitHub/Honors-Thesis-ADA-project/data/input/district/'
    output_csv = 'c:/Users/conno/OneDrive/Documents/GitHub/Honors-Thesis-ADA-project/data/output/dates.csv'
    main(dir1, dir2, output_csv)
