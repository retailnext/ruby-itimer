require 'mkmf'

$CFLAGS = "-g -O2 -Wall"

if have_header('sys/time.h')
  create_makefile 'itimer'
end
