#ifndef ERL_COMM_H
#define ERL_COMM_H

#include <ei.h>

int read_bytes(char *buf, int len);
int write_bytes(char *buf, int len);

int read_opcode();
int read_payload_length();

int read_message(char *buf, int len);
void write_message(ei_x_buff *buf);

int ei_decode_nt_binary(const char *buf, int *index, void *p, long *len);

#endif
