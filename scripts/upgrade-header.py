#!/usr/bin/env python3
import sys
from pathlib import Path


def clean_license_header(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()
    for i, line in enumerate(lines):
        if not line.lstrip().startswith("//"):
            cleaned_lines = lines[i:]
            break
    else:
        cleaned_lines = []
    while cleaned_lines and cleaned_lines[0].strip() == "":
        cleaned_lines.pop(0)
    with open(file_path, "w", encoding="utf-8") as f:
        f.write("".join(cleaned_lines))


def add_license_header(file_path, header_content):
    header_lines = [
        f"// {line.rstrip()}" if line.strip() else "//"
        for line in header_content.splitlines()
    ]
    formatted_header = "\n".join(header_lines)
    new_content = formatted_header + "\n\n"
    with open(file_path, "r", encoding="utf-8") as f:
        original_content = f.read()

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(new_content + original_content)


def main():
    header_path = Path("./license-header.txt")
    if not header_path.exists():
        print("Error: license-header.txt not found", file=sys.stderr)
        sys.exit(1)

    try:
        with open(header_path, "r", encoding="utf-8") as f:
            header_content = f.read()
    except Exception as e:
        print(f"Error reading license header: {str(e)}", file=sys.stderr)
        sys.exit(1)

    src_dir = Path("./src")
    if not src_dir.exists():
        print("Error: ./src directory not found", file=sys.stderr)
        sys.exit(1)

    for file_path in src_dir.rglob("*"):
        if file_path.is_file():
            try:
                clean_license_header(file_path)
            except Exception as e:
                print(
                    f"Error cleaning header in {file_path}: {str(e)}", file=sys.stderr
                )
                continue
            try:
                add_license_header(file_path, header_content)
            except Exception as e:
                print(f"Error adding header in {file_path}: {str(e)}", file=sys.stderr)
                continue


if __name__ == "__main__":
    main()
