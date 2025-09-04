import yaml
import sys

def validate_yaml(file_path):
    try:
        with open(file_path, 'r') as f:
            yaml.safe_load(f)
        print(f"PASS: {file_path} YAML syntax is valid")
        return True
    except yaml.YAMLError as e:
        print(f"FAIL: {file_path} YAML syntax error:")
        if hasattr(e, 'problem_mark'):
            mark = e.problem_mark
            print(f"  Error position: line {mark.line+1}, column {mark.column+1}")
        print(f"  Details: {e}")
        return False
    except Exception as e:
        print(f"ERROR: {file_path} could not be read: {e}")
        return False

if __name__ == "__main__":
    files_to_validate = [
        ".github/workflows/build.yml",
        ".github/workflows/android-build.yml"
    ]
    
    all_valid = True
    for file_path in files_to_validate:
        if not validate_yaml(file_path):
            all_valid = False
    
    if not all_valid:
        sys.exit(1)