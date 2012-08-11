require 'mkmf'

$CFLAGS = "-g -O2 -Wall -Werror"

if have_header('sys/time.h')
  create_makefile 'itimer_native'
end
