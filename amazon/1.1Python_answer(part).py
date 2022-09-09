# Q5
from numpy import average


def count_upper_case(filepath):
    with open(filepath, 'r') as file:
        count = 0
        content = file.read()
        for i in content:
            if i.isupper():
                count+=1
    return count

print(count_upper_case('test.txt'))

# Q6
import numpy as np

# 自定义 Exception
class KeywordNotFound(Exception):
    def __init__(self, msg):
        self.msg = msg
    
    def __str__(self):
        return self.msg

class NotAllNumbers(Exception):
    def __init__(self, msg):
        self.msg = msg
    
    def __str__(self):
        return self.msg

def print_avg(keyarg, scores):
    keys = list(keyarg.keys())
    if 'student_name' not in keys or 'student_age' not in keys:
        raise KeywordNotFound('Incomplete keywords')
    if not all(isinstance(score,int) or isinstance(score,float) for score in scores): 
        raise NotAllNumbers("It's not all about numbers")
    
    return 'name: {}, age: {}, avg: {}'.format(keyarg['student_name'], keyarg['student_age'],
                                               np.mean(scores))

keyarg = {'student_name':'Jack', 'student_age':19, 'hobby': 'soccer'}
scores = [90, 89, 98, 88]
keyarg = {'student_name':'Hailey', 'blackboard':'stitch', 'nineteen': 'addict',
          'special': 'housework'}
scores = [90, 89, 98, 88, 'judicial']
print(print_avg(keyarg, scores))