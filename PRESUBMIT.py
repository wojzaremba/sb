#!/usr/bin/python

import os
import re
import subprocess
import sys
import signal
from subprocess import call

modified = re.compile('^[ ]*(?:M|A)(\s+)(?P<name>.*)')


def cleanup():
  # Unstash changes to the working tree that we had stashed
  print 'Unstashing the changes'
  # TODO(karol): uncomment this after making sure it doesn't break the workflow
  # subprocess.call(['git', 'reset', '--hard'],
  #                 stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  # subprocess.call(['git', 'stash', 'pop', '--quiet', '--index'], 
  #                 stdout=subprocess.PIPE, stderr=subprocess.PIPE)

def signal_handler(signum, frame):
  print 'Signal handler called with signal', signum
  cleanup()
  os._exit(signum)

def register_all_signals():
  print 'Registering important signal handlers'
  signals = (
      'SIGHUP', 'SIGINT', 'SIGQUIT', 'SIGILL',
      'SIGABRT', 'SIGFPE', 'SIGSEGV', 'SIGTERM')
  for sig in signals:
    try:
      signum = getattr(signal, sig)
      signal.signal(signum, signal_handler)
    except RuntimeError:
      print "Skipping %s" % sig
    except ValueError:
      print 'Out of range: %s' % sig

def matches_file(file_name, match_files):
  return any(
      re.compile(match_file).match(file_name) for match_file in match_files)


def check_files(files, check):
  result = 0
  print check['output']
  for file_name in files:
    is_matched = ((not 'match_files' in check) or
        matches_file(file_name, check['match_files']))
    not_ignored = ((not 'ignore_files' in check) or 
        not matches_file(file_name, check['ignore_files']))
    if is_matched and not_ignored:
      process = subprocess.Popen(
          check['command'] % file_name,
          stdout=subprocess.PIPE,
          stderr=subprocess.PIPE, shell=True)
      out, err = process.communicate()
      if out or err:
        if check['print_filename']:
          prefix = '\t%s:' % file_name
        else:
          prefix = '\t'
        output_lines = ['%s%s' % (prefix, line) for line in out.splitlines()]
        print '\n'.join(output_lines)
        if err:
          print err
        if check['should_stop_commit']:
          result = 1
  return result


def main(all_files):
  register_all_signals()
  files = []
  if all_files:
    for root, _, file_names in os.walk('.'):
      for file_name in file_names:
        files.append(os.path.join(root, file_name))
  else:
    p = subprocess.Popen(
        ['git', 'status', '--porcelain'], stdout=subprocess.PIPE)
    out, _ = p.communicate()
    for line in out.splitlines():
      match = modified.match(line)
      if match:
        files.append(match.group('name'))
  
  # Run unit tests
  tests_result = call(["matlab", "-nojvm -nosplash -nodisplay -r", "\"try test_all(); catch exit(-1);end;exit(0);\""])
  
  # Fail iff tests failed. TODO(karol): change to "tests_result or result"
  # in the future.
  if tests_result == 0:
    print "Tests were successful!"
    sys.exit(0)
  else:
    print "Tests failed"
    sys.exit(1)

if __name__ == '__main__':
  all_files = False
  if len(sys.argv) > 1 and sys.argv[1] == '--all-files':
    all_files = True
  main(all_files)
