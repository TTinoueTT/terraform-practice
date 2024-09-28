import os
import re
import hcl2
import sys
import json

# process part
if len(sys.argv) != 2:
    print("augment error use: python variable-bundle.py '<main.tf path>'")
    sys.exit(1)

main_tf_path = sys.argv[1]

# Extract variables from main.tf
# main.tfから変数を取り出す
def list_ref_main_tf(main_path):
    with open(main_path + "/main.tf", 'r') as file:
        content = file.read()
        # print(content)
    return set(re.findall(r'var\.(\w+)', content))

# List declared variables in .tf files on the same level as main.tf
# main.tf と同階層の .tf ファイルで宣言済み変数をリストする
def list_variable_from_tf_files(directory):
    variables = set()
    for file in os.listdir(directory):
        if file.endswith('.tf'):
            with open(os.path.join(directory, file), 'r') as f:
                tf_dict = hcl2.load(f)
                if 'variable' in tf_dict:
                    for var_block in tf_dict['variable']:
                        # 各 var_block は変数名をキーとする辞書
                        for var_name in var_block.keys():
                            variables.add(var_name)
    return variables

# Get variables from module files
# モジュールファイルから変数を取得する
def get_module_variables(module_path):
    module_vars = {}
    for file in os.listdir(module_path):
        if file.endswith('_variable.tf'):
            with open(os.path.join(module_path, file), 'r') as f:
                tf_dict = hcl2.load(f)
                if 'variable' in tf_dict:
                    for var_block in tf_dict['variable']:
                        for var_name, var_def in var_block.items():
                            module_vars[var_name] = var_def
    return module_vars

def process_value(value):
    if isinstance(value, str):
        value = value.strip('"')
        value = remove_outer_braces(value)
        value = remove_all_braces(value)
        return value
    elif isinstance(value, list):
        return [process_value(v) for v in value]
    elif isinstance(value, dict):
        return {k: process_value(v) for k, v in value.items()}
    else:
        return value

def remove_outer_braces(value):
    if value.startswith('${') and value.endswith('}'):
        return value[2:-1]
    else:
        return value

def remove_all_braces(value):
    pattern = re.compile(r'\$\{([^{}]+)\}')
    while True:
        new_value, count = pattern.subn(r'\1', value)
        if count == 0:
            break
        value = new_value
    return value

def format_value(value, wrap_strings=True, indent=0):
    indent_str = '  ' * indent
    if isinstance(value, str):
        if wrap_strings:
            return f'"{value}"'
        else:
            return value
    elif isinstance(value, bool):
        return str(value).lower()
    elif isinstance(value, (int, float)):
        return str(value)
    elif isinstance(value, list):
        if not value:
            return '[]'
        items = []
        for v in value:
            items.append(format_value(v, wrap_strings, indent+1))
        return '[\n' + ',\n'.join(f"{indent_str}  {item}" for item in items) + f'\n{indent_str}]'
    elif isinstance(value, dict):
        if not value:
            return '{}'
        items = []
        for k, v in value.items():
            items.append(f"{indent_str}  {k} = {format_value(v, wrap_strings, indent+1)}")
        return '{\n' + '\n'.join(items) + f'\n{indent_str}}}'
    else:
        return json.dumps(value)

def format_type(type_str):
    # シングルクォートを削除
    type_str = type_str.replace("'", "")
    # コロンを等号に置換
    type_str = type_str.replace(":", " =")
    # カンマの後にスペースを追加
    type_str = re.sub(r',\s*', ', ', type_str)
    return type_str


def prepare_bundle_variable_content(variables):
    content = []
    for var_name, var_def in variables.items():
        content.append(f'variable "{var_name}" {{')
        for key, value in var_def.items():
            value = process_value(value)
            if key == 'type':
                formatted_value = format_type(value)
                # formatted_value = format_value(value, wrap_strings=False, indent=1)
            else:
                formatted_value = format_value(value, wrap_strings=True, indent=1)
            content.append(f'  {key} = {formatted_value}')
        content.append('}\n')
    return '\n'.join(content)

# Write variables to bundle_variable.tf
def write_to_bundle_variable(content, output_path):
    with open(output_path, 'w') as f:
        f.write(content)

# カレントディレクトリのmain.tfをチェックし、使用されているすべての変数（接頭辞がvar.のもの）をリストアップします。
# 同じディレクトリの .tf ファイルで宣言されている変数は、このリストから削除されます。
# modules/network/vpc/ ディレクトリの *_variable.tf ファイルで宣言された変数をチェックします。
# 最後に、main.tf で使用されているが、ローカルで宣言されていないモジュールの変数を bundle_variable.tf に追加します。


# ****************
# main process
# ****************

# Step 1: Check main.tf and list variables
main_var_list=list_ref_main_tf(main_tf_path)

# Step 2: Remove variables declared in the same level
declared_vars = list_variable_from_tf_files(main_tf_path)
main_var_list -= declared_vars

modules_path_list = []

# Open the file and read each line
with open(main_tf_path + "/shells/modules-pass.txt", 'r') as file:
    for line in file:
        # Remove any leading/trailing whitespace and newline characters
        line = line.strip()
        # Add the line to the list if it's not empty
        if line:
            modules_path_list.append(line)

# Print the resulting list
# print(modules_path_list)

for module_path in modules_path_list:
    module_vars = get_module_variables(module_path)
    # Step 3: Check module variables
    # module_path = os.path.join(main_tf_path, 'modules', 'network', 'vpc')
    module_vars = get_module_variables(module_path)

    # Step 4: Add missing variables to bundle_variable.tf
    # bundle_variable.tfに不足している変数を追加
    variables_to_add = {var: module_vars[var] for var in main_var_list if var in module_vars}

    bundle_content = prepare_bundle_variable_content(variables_to_add)
    # print(bundle_content)

    write_to_bundle_variable(bundle_content, os.path.join(main_tf_path, 'bundle_variable.tf'))
    print(f"Added {len(variables_to_add)} variables {module_path} to bundle_variable.tf")
