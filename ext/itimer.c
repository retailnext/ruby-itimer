#include <ruby.h>
#include <sys/time.h>
#include <unistd.h>

VALUE itimer_real;
VALUE itimer_virtual;
VALUE itimer_prof;

int which_from_val(VALUE which_val) {
  return which_val == itimer_real
    ? ITIMER_REAL
    : which_val == itimer_virtual
      ? ITIMER_VIRTUAL
      : ITIMER_PROF;
}

VALUE rb_itimer_get(VALUE self, VALUE which_val) {
  struct itimerval value;
  getitimer(which_from_val(which_val), &value);

  return DBL2NUM(value.it_value.tv_sec + (double)value.it_value.tv_usec/1000000);
}

VALUE rb_itimer_get_interval(VALUE self, VALUE which_val) {
  struct itimerval value;
  getitimer(which_from_val(which_val), &value);

  return DBL2NUM(value.it_interval.tv_sec + (double)value.it_interval.tv_usec/1000000);
}

VALUE rb_itimer_set(VALUE self, VALUE which_val, VALUE new_value) {
  struct itimerval value;
  getitimer(which_from_val(which_val), &value);

  double dbl_value = NUM2DBL(new_value);

  value.it_value.tv_sec = floor(dbl_value);
  value.it_value.tv_usec = (dbl_value - floor(dbl_value)) * 1000000;

  int ret = setitimer(which_from_val(which_val), &value, NULL);
  if (ret != 0) {
    rb_sys_fail(0);
  } else {
    return Qtrue;
  }
}

VALUE rb_itimer_set_interval(VALUE self, VALUE which_val, VALUE new_value) {
  struct itimerval value;
  getitimer(which_from_val(which_val), &value);

  value.it_interval.tv_sec = NUM2INT(new_value);
  value.it_interval.tv_usec = 0;

  int ret = setitimer(which_from_val(which_val), &value, NULL);
  if (ret != 0) {
    rb_sys_fail(0);
  } else {
    return Qtrue;
  }
}

void Init_itimer(void) {
  VALUE itimer_class = rb_define_class("Itimer", rb_cObject);

  rb_define_singleton_method(itimer_class, "get", rb_itimer_get, 1);
  rb_define_singleton_method(itimer_class, "get_interval", rb_itimer_get_interval, 1);
  rb_define_singleton_method(itimer_class, "set", rb_itimer_set, 2);
  rb_define_singleton_method(itimer_class, "set_interval", rb_itimer_set_interval, 2);

  itimer_real = ID2SYM(rb_intern("real"));
  itimer_virtual = ID2SYM(rb_intern("virtual"));
  itimer_prof = ID2SYM(rb_intern("prof"));
}
