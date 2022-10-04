import sys

# split specs to separate file
from machine import instructions, registers

def parse_number(s):
    try:
        if len(s) > 2 and s[0] == '0':
            # base prefix number
            num = s[2:] # get number part

            if s[1] == 'b': 
                return int(num, 2) # base 2
            elif s[1] == 'o': 
                return int(num, 8) # base 8
            elif s[1] == 'x': 
                return int(num, 16) # base 16
            else:
                return None
        else:
            return int(s) # base 10 number

    except ValueError:
        return None

def parse_address(s):
    return s[1:-1] if s[0] == '[' and s[-1] == ']' else None

ARG_NUMBER = 1
ARG_REGISTER = 2

ARG_ADDRESS_NUMBER = 3
ARG_ADDRESS_REGISTER = 4

with open(sys.argv[1], 'r') as handle, open(sys.argv[2], 'w') as out:
    # byte binary string buffer
    binary = []

    def emit(op = None, rd = None, rs = None, data = None):
        if op:
            if op in instructions:
                # print(f'emit {op}')
                code = instructions[op]
                if rd is not None:
                    # print(f'rd = {rd}')
                    code = code.replace('dd', f'{rd:02b}')
                if rs is not None:
                    # print(f'rs = {rs}')
                    code = code.replace('ss', f'{rs:02b}')

                binary.append(code)

                if data is not None:
                    # print(f'data = {data}')
                    binary.append(f'{data:08b}')
            else:
                print(f'unknow op: {op}')
        else:
            # print(f'put {data}')
            binary.append(f'{data:08b}')

    # label address table
    labels = {}

    def parse_arg(s):
        if s in registers:
            return ARG_REGISTER, registers[s]

        s_address = parse_address(s)

        if s_address is not None:
            if s_address in registers:
                return ARG_ADDRESS_REGISTER, registers[s_address]
            if s_address in labels:
                return ARG_ADDRESS_NUMBER, labels[s_address]

            s_address_number = parse_number(s_address)
            if s_address_number is not None:
                return ARG_ADDRESS_NUMBER, s_address_number

        else:
            s_number = parse_number(s)
            if s_number is not None:
                return ARG_NUMBER, s_number

        return None

    # forwarded reference label that need to patch at end of parsing
    pending_label = []

    for buff in handle:
        if not buff:
            break

        buff = buff.strip()

        if not buff or buff[0] == '#':
            # empty line or comment line
            continue

        label, have_label, rest = buff.partition(':')
        label = label.strip()

        if have_label:
            labels[label] = len(binary) # store current address that label appear
            # update buff with text after that
            buff = rest.strip()

        if not buff:
            # just label
            continue

        inst, have_arg, arg = buff.partition(' ')
        inst = inst.strip()

        args = []
        if have_arg:
            arg = arg.strip()
            for item in arg.split(','):
                item = item.strip()
                args.append(item)

        if inst == 'NOP':
            emit('NOP')

        elif inst == 'DATA':
            if len(args) > 0:
                for item in args:
                    if item:
                        number = parse_number(item)
                        if number is not None:
                            emit(data = number)
                        else:
                            print(f'invalid DATA operand')
                    else:
                        print(f'empty DATA operand')
            else:
                print(f'DATA need operand')

        elif inst == 'MOV':
            # load and store operation, use MOV for convenience and select correct instruction for user
            if len(args) == 2:
                left, right = args

                left = parse_arg(left)
                right = parse_arg(right)

                if left and right:
                    left_type, left = left
                    right_type, right = right

                    if left_type == ARG_REGISTER and right_type == ARG_NUMBER:
                        # load immediate
                        emit('LD_immediate', rd = left, data = right)

                    elif left_type == ARG_REGISTER and right_type == ARG_ADDRESS_NUMBER:
                        # load direct
                        emit('LD_direct', rd = left, data = right)

                    elif left_type == ARG_REGISTER and right_type == ARG_ADDRESS_REGISTER:
                        # load indirect
                        emit('LD_indirect', rd = left, rs = right)

                    elif left_type == ARG_ADDRESS_NUMBER and right_type == ARG_REGISTER:
                        # store direct
                        emit('ST_direct', rs = right, data = left)

                    elif left_type == ARG_ADDRESS_REGISTER and right_type == ARG_REGISTER:
                        # store indirect
                        emit('ST_indirect', rd = left, rs = right)

                    elif left_type == ARG_REGISTER and right_type == ARG_REGISTER:
                        # move
                        emit('TRANSFER', rd = left, rs = right)

                    else:
                        print(f'invalid MOV operation')

                else:
                    if not left:
                        print(f'missing MOV first operand')
                    if not right:
                        print(f'missing MOV second operand')
            else:
                print(f'MOV need 2 operands')

        elif inst in ['CMP', 'ADC', 'SBC', 'AND', 'OR' , 'XOR']:
            # binary data operation
            if len(args) == 2:
                left, right = args

                left = parse_arg(left)
                right = parse_arg(right)

                if left and right:
                    left_type, left = left
                    right_type, right = right

                    if left_type == ARG_REGISTER and right_type == ARG_REGISTER:
                        emit(inst, rd = left, rs = right)

                    else:
                        print(f'invalid {inst} operation')

                else:
                    if not left:
                        print(f'missing {inst} first operand')

                    if not right:
                        print(f'missing {inst} second operand')
            else:
                print(f'{inst} need 2 operands')

        elif inst in ['RL', 'RR']:
            # unary data operation
            if len(args) == 1:
                left = args[0]
                left = parse_arg(left)

                if left:
                    left_type, left = left
                    if left_type == ARG_REGISTER:
                        emit(inst, rd = left)
                    else:
                        print(f'invalid {inst} operation')
                else:
                    print(f'missing {inst} first operand')
            else:
                print(f'{inst} need 1 operand')

        elif inst in ['SC', 'CC']:
            emit(inst)

        elif inst in ['J', 'JC', 'JV', 'JN', 'JZ']:
            if len(args) == 1:
                left = args[0]
                if left:
                    location = len(binary) # address that jump instruction will get
                    pending_label.append((location, left))

                    emit(inst, data = 0b11111111)
                else:
                    print(f'missing {inst} first operand')
            else:
                print(f'{inst} need 1 operand')

        elif inst == 'HALT':
            # halt
            emit('HALT')

        else:
            print(f'unknow instruction: {inst}')

    # patch pending label
    for location, label in pending_label:
        if label in labels:
            # update jump address
            binary[location + 1] = f'{labels[label]:08b}'
        else:
            print(f'unknow label: {label}')

    for item in binary:
        print(item, file=out)
