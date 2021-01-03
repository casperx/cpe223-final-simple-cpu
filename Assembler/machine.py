registers = {}

registers['X'] = 1
registers['Y'] = 2
registers['Z'] = 3


instructions = {}

instructions['NOP'] = '00000000'

instructions['LD_immediate'] = '0010dd00'

instructions['LD_direct'] = '0000dd00'
instructions['ST_direct'] = '000100ss'

instructions['LD_indirect'] = '0000ddss'
instructions['ST_indirect'] = '0001ddss'

instructions['TRANSFER'] = '0010ddss'

instructions['SC'] = '11100000'
instructions['CC'] = '11010000'

instructions['ADC'] = '0101ddss'
instructions['SBC'] = '0110ddss'

instructions['CMP'] = '0100ddss'

instructions['AND'] = '1000ddss'
instructions['OR'] = '1001ddss'
instructions['XOR'] = '1010ddss'

instructions['RL'] = '1100dd00'
instructions['RR'] = '1101dd00'

instructions['J'] = '01000000'

instructions['JC'] = '11000000'
instructions['JV'] = '01010000'
instructions['JN'] = '01100000'
instructions['JZ'] = '10000000'

instructions['HALT'] = '11110000'