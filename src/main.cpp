#include <cstring>
#include "erl_comm.h"
#include "soloud.h"
#include "soloud_speech.h"
#include "soloud_wav.h"
#include "soloud_wavstream.h"
#include "soloud_openmpt.h"
#include "soloud_thread.h"

#define MAX_READ 1023
#define MAX_BINARY_SIZE 256

#ifndef MAX_WAVSTREAMS
  #define MAX_WAVSTREAMS 256
#endif

#define OP_CLOSE          -1
#define OP_LOAD_WAVSTREAM  1
#define OP_LOAD_WAV        2
#define OP_PLAY           10
#define OP_STOP           11
#define OP_SEEK           12

#define NUM_TYPES         2

#define TYPE_WAVSTREAM    0
#define TYPE_WAV          1

#define RES_SUCCESS 0

char buffer[MAX_READ + 1];

int main() {
  SoLoud::Soloud soloud;
  SoLoud::WavStream soloud_wavstreams[MAX_WAVSTREAMS];

  soloud.init();

  for(;;) {
    int index = 0;
    int _version;
    int msg_length = read_payload_length() - 1; // Opcode is 1 byte
    int op = read_opcode();
    if (op != OP_CLOSE)
      read_bytes(buffer, msg_length);

    switch(op) {
      case OP_LOAD_WAVSTREAM: {
        int _tuple_length;
        long path_length;
        char file_path[MAX_BINARY_SIZE];
        unsigned long sound_slot;

        ei_decode_version(buffer, &index, &_version);
        ei_decode_tuple_header(buffer, &index, &_tuple_length);
        ei_decode_nt_binary(buffer, &index, &file_path, &path_length);
        ei_decode_ulong(buffer, &index, &sound_slot);

        sound_slot %= MAX_WAVSTREAMS;

        SoLoud::WavStream* stream = soloud_wavstreams + sound_slot;

        int load_result = stream->load(file_path);

        fprintf(stderr, "Loaded wavstream %lu\n", sound_slot);

        ei_x_buff ret_buffer;
        ei_x_new_with_version(&ret_buffer);

        if (load_result == RES_SUCCESS) {
          ei_x_encode_tuple_header(&ret_buffer, 2);
          ei_x_encode_atom(&ret_buffer, "ok");
          ei_x_encode_ulong(&ret_buffer, sound_slot);
        } else {
          char err_string[MAX_BINARY_SIZE];
          strcpy(err_string, soloud.getErrorString(load_result));

          ei_x_encode_tuple_header(&ret_buffer, 2);
          ei_x_encode_atom(&ret_buffer, "error");
          ei_x_encode_binary(&ret_buffer, err_string, strlen(err_string));
        }

        write_message(&ret_buffer);
        ei_x_free(&ret_buffer);
        break;
      }
      case OP_PLAY: {
        int _tuple_length;
        long sound_type;
        long sound_index;
        ei_decode_version(buffer, &index, &_version);
        ei_decode_tuple_header(buffer, &index, &_tuple_length);

        // Sound identification
        ei_decode_tuple_header(buffer, &index, &_tuple_length);
        ei_decode_long(buffer, &index, &sound_type);
        ei_decode_long(buffer, &index, &sound_index);

        // Default Opts
        int opts_length;
        double aVolume = -1.0f;
        double aPan = 0.0f;
        int aPaused = 0;
        unsigned long aBus = 0;

        // Opt list parsing
        ei_decode_list_header(buffer, &index, &opts_length);
        for(int i=0; i<opts_length; ++i) {
          char option_string[MAX_BINARY_SIZE];
          ei_decode_tuple_header(buffer, &index, &_tuple_length);
          ei_decode_atom(buffer, &index, option_string);

          if (strcmp(option_string, "volume")==0) {
            ei_decode_double(buffer, &index, &aVolume);
          } else if (strcmp(option_string, "pan")==0) {
            ei_decode_double(buffer, &index, &aPan);
          } else if (strcmp(option_string, "paused?")==0) {
            ei_decode_boolean(buffer, &index, &aPaused);
          } else if (strcmp(option_string, "bus")==0) {
            ei_decode_ulong(buffer, &index, &aBus);
          }
        }

        unsigned int handle = -1;

        switch(sound_type) {
          case TYPE_WAVSTREAM: {
            fprintf(stderr, "Playing wavstream %ld", sound_index);
            handle = soloud.play(soloud_wavstreams[sound_index], aVolume, aPan, aPaused, aBus);
            break;
          }
          default: {
            fprintf(stderr, "Unhandled sound type: %ld\n", sound_type);
            break;
          }
        }

        ei_x_buff ret_buffer;
        ei_x_new_with_version(&ret_buffer);

        ei_x_encode_tuple_header(&ret_buffer, 2);
        ei_x_encode_atom(&ret_buffer, "ok");
        ei_x_encode_long(&ret_buffer, handle);

        write_message(&ret_buffer);
        ei_x_free(&ret_buffer);
        break;
      }
      case OP_STOP: {
        unsigned long sound_handle;
        ei_decode_version(buffer, &index, &_version);
        ei_decode_ulong(buffer, &index, &sound_handle);

        soloud.stop(sound_handle);

        ei_x_buff ret_buffer;
        ei_x_new_with_version(&ret_buffer);

        ei_x_encode_atom(&ret_buffer, "ok");

        write_message(&ret_buffer);
        ei_x_free(&ret_buffer);
        break;
      }
      case OP_SEEK: {
        unsigned long sound_handle;
        int _tuple_arity;
        double seek_pos;
        ei_decode_version(buffer, &index, &_version);
        ei_decode_tuple_header(buffer, &index, &_tuple_arity);
        ei_decode_ulong(buffer, &index, &sound_handle);
        ei_decode_double(buffer, &index, &seek_pos);

        fprintf(stderr, "Seeking to %lf\n", seek_pos);

        soloud.seek(sound_handle, seek_pos);

        ei_x_buff ret_buffer;
        ei_x_new_with_version(&ret_buffer);

        ei_x_encode_atom(&ret_buffer, "ok");

        write_message(&ret_buffer);
        ei_x_free(&ret_buffer);
        break;
      }
      case OP_CLOSE: {
        fprintf(stderr, "Closed communication.\n");
        soloud.deinit();
        return 0;
      }
      default: {
        fprintf(stderr, "Unhandled opcode: %d\n", op);
        break;
      }
    }
  }
}
