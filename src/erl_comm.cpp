#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <errno.h>
#include <string>
#include <ei.h>

int read_bytes(char *buffer, int len) {
  int count, got = 0;

  do {
    count = read(STDIN_FILENO, buffer+got, len-got);

    if (count == 0) //EOF
      return -1;

    if(count < 0 && errno != EINTR)
      err(EXIT_FAILURE, "Read failure!");

    got += count;
  } while (got<len);

  return(len);
}

int write_bytes(const char *buffer, int len) {
  int count, wrote = 0;

  do {
    count = write(1, buffer+wrote, len-wrote);

    if (count <= 0 && errno != EINTR)
      err(EXIT_FAILURE, "Write failure!");

    wrote += count;
  } while (wrote<len);

  return (len);
}

int read_opcode() {
  char size_header[1];

  if(read_bytes(size_header, 1) < 0) {
    return -1;
  }

  return size_header[0];
}

int read_payload_length() {
  char size_header[2];

  if(read_bytes(size_header, 2) < 0) {
    return -1;
  }

  return (size_header[0] << 8) | size_header[1];
}

void read_message(char *buffer, int len) {
  read_bytes(buffer, len);
  buffer[len] = '\0';
}

void write_message(ei_x_buff *buffer) {
  unsigned char li[2];
  int len = buffer->index;

  li[0] = (len >> 8) & 0xff;
  li[1] = len & 0xff;

  write(STDOUT_FILENO, li, 2);
	write(STDOUT_FILENO, buffer->buff, len);
}

// Returns a null-terminated binary
int ei_decode_nt_binary(const char *buf, int *index, void *p, long *len) {
  int ret = ei_decode_binary(buf, index, p, len);
  *((char *) p + *len) = '\0';
  return ret;
}
