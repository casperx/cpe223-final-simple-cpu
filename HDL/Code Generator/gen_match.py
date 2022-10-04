import sys

with open(sys.argv[1], 'r') as handle, open(sys.argv[2], 'w') as out:
    exists = []

    for line in handle:
        if not line:
            break

        line = line.strip()
        if not line or line[0] == '#':
            continue

        inst, _, pattern = line.partition(',')

        inst = inst.strip()
        pattern = pattern.strip()

        op, rd, rs = pattern.split(' ')

        for exist_inst, exist_op, exist_rd, exist_rs in exists:
            if op == exist_op and rd == exist_rd and rs == exist_rs:
                print(f'duplicate op: {inst} with {exist_inst}')
                break
        else:
            exists.append((inst, op, rd, rs))

            check = '''op == 4'b{op} & rd {cmp_rd} 2'b00 & rs {cmp_rs} 2'b00'''.format(
                op=op, 
                cmp_rd='==' if rd == '00' else '!=', 
                cmp_rs='==' if rs == '00' else '!='
            )

            print(f'wire {inst} = {check};', file = out)
