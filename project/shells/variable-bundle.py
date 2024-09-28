import re
import sys
import hcl2
import io

if len(sys.argv) != 3:
    print("augment error use: python script.py '<main.tf text>' '<module **_variable.tf text>'")
    sys.exit(1)

main_tf_txt = sys.argv[1]
module_variables_txt = sys.argv[2]

# 正規表現で main.tf 内で記述されているの変数名を抽出
# 変数名は 最初の文字は英字（大文字小文字）またはアンダースコア、2文字目以降は英数字またはアンダースコア
main_tf_vars = re.findall(r'var\.([a-zA-Z_][a-zA-Z0-9_]*)', main_tf_txt)

# 結果を表示
print("main.tf で使用されている変数名:")
for var in main_tf_vars:
    print(var)


print("module 配下:")
print("*****************************************")
module_v_map = []


with io.StringIO(module_variables_txt) as fp:
    obj = hcl2.load(fp)
    print(obj)

module_variables = obj.get('variable', [])

sys.exit()
print(module_variables)
module_vars_dict = {}

for var_block in module_variables:
    # 各 var_block は変数名をキーとする辞書
    for var_name, var_attrs in var_block.items():
        module_vars_dict[var_name] = var_attrs

print()
print(module_vars_dict)
print()
# # 結果を表示
# for var in module_v_map:
#     print(f'key="{var["key"]}", value={var["value"]}')
#     print()

variables_to_add = {}

for var_name in main_tf_vars:
    if var_name in module_vars_dict:
        variables_to_add[var_name] = module_vars_dict[var_name]

existing_vars = set()
try:
    with open('main_variable.tf', 'r') as f:
        existing_content = f.read()
        existing_vars.update(re.findall(r'variable\s+"([a-zA-Z_][a-zA-Z0-9_]*)"', existing_content))
except FileNotFoundError:
    # main_variable.tf が存在しない場合は新規作成
    pass

# 収集した変数定義を表示
print("\nmain_variable.tf に追加する変数定義:")
for var_name, var_attrs in variables_to_add.items():
    if var_name in existing_vars:
        continue  # 既に存在する場合はスキップ
    print(f'variable "{var_name}" {{')
    for attr_key, attr_value in var_attrs.items():
        # 値が文字列の場合、適切に処理
        if isinstance(attr_value, str):
            if attr_value.startswith('${') and attr_value.endswith('}'):
                attr_value = attr_value[2:-1]
            if not (attr_value.startswith('"') and attr_value.endswith('"')):
                attr_value = f'"{attr_value}"'
        print(f'  {attr_key} = {attr_value}')
    print('}\n')

# main_variable.tf に書き込む
with open('main_variable.tf', 'a') as f:
    for var_name, var_attrs in variables_to_add.items():
        if var_name in existing_vars:
            continue  # 既に存在する場合はスキップ
        f.write(f'variable "{var_name}" {{\n')
        for attr_key, attr_value in var_attrs.items():
            # 値が文字列の場合、引用符で囲む
            if isinstance(attr_value, str):
                # "${string}" の形式を "string" に変換
                if attr_value.startswith('${') and attr_value.endswith('}'):
                    attr_value = attr_value[2:-1]
                # 既に引用符で囲まれていない場合、囲む
                if not (attr_value.startswith('"') and attr_value.endswith('"')):
                    attr_value = f'"{attr_value}"'
            f.write(f'  {attr_key} = {attr_value}\n')
        f.write('}\n\n')
