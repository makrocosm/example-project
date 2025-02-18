#include <stdio.h>
#include <uv.h>

int main(int argc, char **argv) {
  // Does nothing with libuv, but makes sure compilation against libuv works
  uv_loop_t *loop = uv_default_loop();
  uv_run(loop, UV_RUN_DEFAULT);
  uv_loop_close(loop);
  
  printf("Hello world\n");
  return 0;
}
