# Itimer [![Build Status](https://travis-ci.org/nearbuy/ruby-itimer.png)](https://travis-ci.org/nearbuy/ruby-itimer)

Drop-in replacement for stdlib Timeout that uses POSIX interval timers instead of threads.  Not as portable but much lighter weight.  Also includes low-level wrappers for setitimer and getitimer.

## Examples

``` ruby
require 'itimer'

begin
  Itimer.timeout(1) { sleep 5 }
rescue Itimer::Timeout
  puts 'Time expired'
end
```

``` ruby
require 'itimer/compat'

begin
  Timeout::timeout(1) { sleep 5 }
rescue Timeout::Error
  puts 'Time expired'
end
```

``` ruby
require 'itimer'

Signal.trap('VTALRM') { raise Itimer::Timeout }

begin
  # set :real, :virtual and :prof
  Itimer.set(:virtual, 1)
  do\_expensive\_computation()
rescue Itimer::Timeout
  puts 'Execution time expired'
end

Signal.trap('ALRM') { print '.' }

Itimer.set\_interval(:real, 0.5)
do\_expensive\_computation()
puts 'Done'
```

## Support

Please report issues at https://github.com/nearbuy/ruby-itimer/issues

## See Also

getitimer(2), setitimer(2)

## Authors

* Nate Mueller ([natemueller](https://github.com/natemueller))

## License

Copyright (c) 2013 Nearbuy Systems

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
