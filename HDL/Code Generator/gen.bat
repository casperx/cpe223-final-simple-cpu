@echo off
py -3 gen_match.py instruction_pattern.txt control_pattern.txt
py -3 gen_signal.py instruction_step.txt control_signal.txt
pause