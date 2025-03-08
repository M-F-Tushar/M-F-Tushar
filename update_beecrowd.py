import requests
from bs4 import BeautifulSoup
import re

# Your Beecrowd Profile URL
BEEJUDGE_URL = "https://judge.beecrowd.com/en/profile/1083322"  # Replace with your ID

def get_solved_problems():
    response = requests.get(BEEJUDGE_URL)
    if response.status_code == 200:
        soup = BeautifulSoup(response.text, 'html.parser')
        solved_text = soup.find_all("div", class_="col-md-4 col-xs-4")[1]  # Finding "Solved" section
        if solved_text:
            solved_count = solved_text.text.strip().split("\n")[0]  # Extract number
            return solved_count
    return "N/A"

# Read the README file
with open("README.md", "r") as file:
    lines = file.readlines()

solved = get_solved_problems()

# Modify the README dynamically
with open("README.md", "w") as file:
    for line in lines:
        if line.startswith("- **🔢 Problems Solved:**"):
            file.write(f"- **🔢 Problems Solved:** {solved}\n")
        else:
            file.write(line)
