import yaml
import sys

def validate_yaml(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            yaml.safe_load(f)
        print(f"✅ {file_path} YAML语法验证成功")
        return True
    except yaml.YAMLError as e:
        print(f"❌ {file_path} YAML语法验证失败:")
        if hasattr(e, 'problem_mark'):
            mark = e.problem_mark
            print(f"  错误位置: 行 {mark.line+1}, 列 {mark.column+1}")
        print(f"  错误详情: {e}")
        return False
    except Exception as e:
        print(f"❌ {file_path} 文件读取失败: {e}")
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