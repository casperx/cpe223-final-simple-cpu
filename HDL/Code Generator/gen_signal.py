import sys

from collections import defaultdict, Counter


instructions = {}


# parse step file

with open(sys.argv[1], 'r') as f:

	while True:

		line = f.readline()

		line = line.strip()

		if not line:

			# empty line

			break

		if line[0] == '#':

			# comment

			continue


		macro = line[0] == '!'

		name = line[1:] if macro else line


		steps = []


		while True:

			signals = set()


			line = f.readline()

			line = line.strip()

			if not line:

				# empty line

				break

			if line[0] == '#':

				# comment

				continue


			actions = line.split(',')


			for action in actions:

				action = action.strip()


				tokens = action.split(' ')

				if len(tokens) == 3:

					if tokens[1] == '<-':

						# transfer

						signals.add(tokens[0] + '_load')
						signals.add(tokens[2] + '_enable')

					else:

						print('''invalid binary action''')

				elif len(tokens) == 2:

					if tokens[1] == '^':

						# count

						signals.add(tokens[0] + '_count')

					else:

						print('''invalid unary action''')

				else:

					if action[0] == '$':

						# include

						instruction = action[1:]

						for include_signals in instructions[instruction]['steps']:

							steps.append(include_signals)

					else:

						# signal already

						signals.add(action)

			if signals:

				steps.append(signals)


		instruction = {}


		instruction['macro'] = macro

		instruction['steps'] = steps


		instructions[name] = instruction


all_instruction = [] # instruction list


# collect control signals

controls = defaultdict(list)

for instruction in instructions:

	item = instructions[instruction]

	if not item['macro']:

		all_instruction.append(instruction)


		steps = item['steps']

		for step, signals in enumerate(steps):

			for signal in signals:

				cond = {}

				cond['step'] = step

				cond['instruction'] = instruction


				controls[signal].append(cond)


# optimize common instruction control signal

for control in controls:

	conds = controls[control]


	max_step = max((cond['step'] for cond in conds))


	i = 0

	while i <= max_step:


		check = all_instruction[:]


		cond_step = []

		cond_other = []


		# filter

		for cond in conds:

			instruction = cond['instruction']

			if cond['step'] == i:

				cond_step.append(cond)

			else:

				cond_other.append(cond)


		for cond in cond_step:

			instruction = cond['instruction']

			check.remove(instruction)


		# if that step is common for all instruction

		if not check:

			# put other first

			controls[control] = cond_other


			# add single dummy step

			new_cond = {}

			new_cond['step'] = i

			new_cond['instruction'] = 'ALWAYS'


			controls[control].append(new_cond)

		i += 1


# show instruction and steps

for instruction in all_instruction:

	item = instructions[instruction]


	print(instruction)


	steps = item['steps']

	for step, signals in enumerate(steps):

		print(step, ''', '''.join(signals))


# generate control signal

with open(sys.argv[2], 'w') as f:

	keys = controls.keys()

	for control in sorted(keys):

		conds = controls[control]

		def generate_check(cond):

			return ('''(step == %(step)d)''' if cond['instruction'] == 'ALWAYS' else '''(step == %(step)d & %(instruction)s)''') % cond

		maps = ''' |\n    '''.join((generate_check(cond) for cond in conds))

		print('''assign %s =\n    %s;''' % (control, maps), file = f)















