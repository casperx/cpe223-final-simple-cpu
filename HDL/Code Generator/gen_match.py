import sys

with open(sys.argv[1], 'r') as handle, open(sys.argv[2], 'w') as out:

    exists = []

    while True:
    
        line = handle.readline()

        if not line:

            # end of file
            
            break

        line = line.strip()

        if not line or line[0] == '#':

            # empty or comment

            continue


        inst, sep, pattern = line.partition(',')


        inst = inst.strip()

        pattern = pattern.strip()


        op, rd, rs = pattern.split(' ')


        exist = False


        for exist_inst, exist_op, exist_rd, exist_rs in exists:

            if op == exist_op and rd == exist_rd and rs == exist_rs:

                print(f'duplicate op: {inst} with {exist_inst}')

                exist = True

                break


        if not exist:

            exists.append((inst, op, rd, rs))


            check = '''(op == 4'b%s) & (rd %s 2'b00) & (rs %s 2'b00)''' % (op, '==' if rd == '00' else '!=', '==' if rs == '00' else '!=')

            print('''wire %s = %s;''' % (inst, check), file = out)










    








