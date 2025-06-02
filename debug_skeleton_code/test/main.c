#include "debug.h"

void g(int rdi, int rsi, int rdx, int rcx, int r8, int r9)
{
  dump_registers();
  dump_backtrace();
}

int no_op(void) { return 42; }

void f()
{
  no_op();
  g(1, 2, 3, 4, 5, 6);
}

int main()
{
  f();
}
