import re
import sys
import hcl2
import io

def hcl_format(value, indent=0):
    indent_str = "  " * indent
    if isinstance(value, dict):
        items = []
        for k, v in value.items():
            items.append(f'{indent_str}  {k} = {hcl_format(v, indent + 1)}')
        return "{\n" + "\n".join(items) + f'\n{indent_str}}}'
    elif isinstance(value, list):
        items = [f'{hcl_format(v, indent + 1)}' for v in value]
        return "[\n" + ",\n".join(items) + f'\n{indent_str}]'
    elif isinstance(value, str):
        return f'"{value}"'
    else:
        return str(value)

def type_format(value):
    if isinstance(value, dict):
        items = []
        for k, v in value.items():
            items.append(f'    {k} = {type_format(v)}')
        return f'object({{\n' + ',\n'.join(items) + '\n  }})'
    elif isinstance(value, list):
        if len(value) > 0:
            return f'list({type_format(value[0])})'
        else:
            return 'list(any)'
    elif isinstance(value, str):
        # 型情報が文字列として与えられている場合、そのまま返す
        if value.startswith('list(') or value.startswith('object(') or value in ['string', 'number', 'bool', 'any']:
            return value
        else:
            return 'string'
    elif isinstance(value, int):
        return 'number'
    elif isinstance(value, float):
        return 'number'
    elif isinstance(value, bool):
        return 'bool'
    else:
        return 'any'

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

print("\nmodule 配下の変数定義:")
print("*****************************************")
# module_variables_txt をパースして変数定義を取得
with io.StringIO(module_variables_txt) as fp:
    obj = hcl2.load(fp)

module_variables = obj.get('variable', [])

# module_vars_dict を辞書に変換（キー：変数名、値：変数定義）
module_vars_dict = {}

for var_block in module_variables:
    # 各 var_block は変数名をキーとする辞書
    for var_name, var_attrs in var_block.items():
        module_vars_dict[var_name] = var_attrs

# main.tf で使用されている変数の中で、モジュールの変数定義があるものを収集
variables_to_add = {}

for var_name in main_tf_vars:
    if var_name in module_vars_dict:
        variables_to_add[var_name] = module_vars_dict[var_name]

# bundle_variable.tf に既存の変数名を取得
existing_vars = set()
try:
    with open('bundle_variable.tf', 'r') as f:
        existing_content = f.read()
        existing_vars.update(re.findall(r'variable\s+"([a-zA-Z_][a-zA-Z0-9_]*)"', existing_content))
except FileNotFoundError:
    # bundle_variable.tf が存在しない場合は新規作成
    pass

# 収集した変数定義を表示
print("\nbundle_variable.tf に追加する変数定義:")
for var_name, var_attrs in variables_to_add.items():
    if var_name in existing_vars:
        continue  # 既に存在する場合はスキップ
    print(f'variable "{var_name}" {{')
    for attr_key, attr_value in var_attrs.items():
        if attr_key == 'type':
            # type の値を整形
            attr_value = attr_value.strip('"')  # 余分な引用符を削除
            attr_value = type_format(attr_value)
        elif attr_key == 'default':
            # default の値を整形
            attr_value = hcl_format(attr_value)
        else:
            # 値が文字列の場合、適切に処理
            if isinstance(attr_value, str):
                if attr_value.startswith('${') and attr_value.endswith('}'):
                    attr_value = attr_value[2:-1]
                if not (attr_value.startswith('"') and attr_value.endswith('"')):
                    attr_value = f'"{attr_value}"'
        print(f'  {attr_key} = {attr_value}')
    print('}\n')

# bundle_variable.tf に追記
with open('bundle_variable.tf', 'a') as f:
    for var_name, var_attrs in variables_to_add.items():
        if var_name in existing_vars:
            continue  # 既に存在する場合はスキップ
        f.write(f'variable "{var_name}" {{\n')
        for attr_key, attr_value in var_attrs.items():
            if attr_key == 'type':
                attr_value = attr_value.strip('"')  # 余分な引用符を削除
                attr_value = type_format(attr_value)
            elif attr_key == 'default':
                attr_value = hcl_format(attr_value)
            else:
                if isinstance(attr_value, str):
                    if attr_value.startswith('${') and attr_value.endswith('}'):
                        attr_value = attr_value[2:-1]
                    if not (attr_value.startswith('"') and attr_value.endswith('"')):
                        attr_value = f'"{attr_value}"'
            f.write(f'  {attr_key} = {attr_value}\n')
        f.write('}\n\n')
