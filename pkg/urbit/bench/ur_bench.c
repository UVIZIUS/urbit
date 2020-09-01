#include "all.h"
#include "vere/vere.h"
#include "ur/ur.h"

//  XX not declared in serial.h due to presence of ur_* types
//
ur_cue_res_e
u3s_cue_xeno_unsafe(ur_dict32_t* dic_u,
                    c3_d         len_d,
                    const c3_y*  byt_y,
                    u3_noun*       out);

/* _setup(): prepare for tests.
*/
static void
_setup(void)
{
  u3m_init();
  u3m_pave(c3y, c3n);
}

/* _ames_writ_ex(): |hi packet from fake ~zod to fake ~nec
*/
static u3_noun
_ames_writ_ex(void)
{
  c3_y  bod_y[63] = {
    0x30, 0x90, 0x2d,  0x0,  0x0,  0x0,  0x1,  0x0,  0x9, 0xc0, 0xd0,
     0x0,  0x4, 0x40, 0x30, 0xf4,  0xa, 0x3d, 0x45, 0x86, 0x66, 0x2c,
     0x2, 0x38, 0xf8, 0x72, 0xa3,  0x9, 0xf6,  0x6, 0xf3,  0x0, 0xbe,
    0x67, 0x61, 0x49, 0x50,  0x4, 0x3c, 0x13, 0xb2, 0x96, 0x42, 0x1b,
    0x62, 0xac, 0x97, 0xff, 0x24, 0xeb, 0x69, 0x1b, 0xb2, 0x60, 0x72,
     0xa, 0x53, 0xdf, 0xe8, 0x8a, 0x9c, 0x6f, 0xb3
  };
  u3_noun lan = u3nc(0, 1);
  u3_noun cad = u3nt(c3__send, lan, u3i_bytes(sizeof(bod_y), bod_y));
  u3_noun wir = u3nt(c3__newt, 0x1234, u3_nul);
  u3_noun ovo = u3nc(u3nc(u3_blip, wir), cad);
  u3_noun wen;

  {
    struct timeval tim_u;
    gettimeofday(&tim_u, 0);
    wen = u3_time_in_tv(&tim_u);
  }

  return u3nt(c3__work, 0, u3nc(wen, ovo));
}

static void
_jam_bench(void)
{
  struct timeval b4, f2, d0;
  c3_w  mil_w, i_w, max_w = 10000;
  u3_noun wit = _ames_writ_ex();

  fprintf(stderr, "\r\njam microbenchmark:\r\n");

  {
    gettimeofday(&b4, 0);

    {
      c3_w* wor_w, bit_w;

      for ( i_w = 0; i_w < max_w; i_w++ ) {
        wor_w = u3s_jam_fib(wit, &bit_w);
        u3a_wfree(wor_w);
      }
    }

    gettimeofday(&f2, 0);
    timersub(&f2, &b4, &d0);
    mil_w = (d0.tv_sec * 1000) + (d0.tv_usec / 1000);
    fprintf(stderr, "  jam og: %u ms\r\n", mil_w);
  }

  {
    gettimeofday(&b4, 0);

    {
      c3_d  len_d;
      c3_y* byt_y;

      for ( i_w = 0; i_w < max_w; i_w++ ) {
        u3s_jam_xeno(wit, &len_d, &byt_y);
        c3_free(byt_y);
      }
    }

    gettimeofday(&f2, 0);
    timersub(&f2, &b4, &d0);
    mil_w = (d0.tv_sec * 1000) + (d0.tv_usec / 1000);
    fprintf(stderr, "  jam xeno: %u ms\r\n", mil_w);
  }

  while ( 1 ) {
    ur_root_t* rot_u = ur_hcon_init();
    c3_d       len_d;
    c3_y*      byt_y;
    ur_nref      ref;

    u3s_jam_xeno(wit, &len_d, &byt_y);
    if ( ur_cue_good != ur_cue(rot_u, len_d, byt_y, &ref) ) {
      fprintf(stderr, " jam bench: cue failed wtf\r\n");
      break;
    }

    c3_free(byt_y);

    {
      gettimeofday(&b4, 0);

      for ( i_w = 0; i_w < max_w; i_w++ ) {
        ur_jam(rot_u, ref, &len_d, &byt_y);
        c3_free(byt_y);
      }

      gettimeofday(&f2, 0);
      timersub(&f2, &b4, &d0);
      mil_w = (d0.tv_sec * 1000) + (d0.tv_usec / 1000);
      fprintf(stderr, "  jam cons: %u ms\r\n", mil_w);
    }

    {
      gettimeofday(&b4, 0);

      {
        ur_dict64_t dic_u = {0};
        c3_d  len_d;
        c3_y* byt_y;

        ur_dict64_grow((ur_root_t*)0, &dic_u, ur_fib10, ur_fib11);

        for ( i_w = 0; i_w < max_w; i_w++ ) {
          ur_jam_unsafe(rot_u, ref, &dic_u, &len_d, &byt_y);
          c3_free(byt_y);
          ur_dict64_wipe(&dic_u);
        }

        ur_dict_free((ur_dict_t*)&dic_u);
      }

      gettimeofday(&f2, 0);
      timersub(&f2, &b4, &d0);
      mil_w = (d0.tv_sec * 1000) + (d0.tv_usec / 1000);
      fprintf(stderr, "  jam cons unsafe: %u ms\r\n", mil_w);
    }

    ur_hcon_free(rot_u);
    break;
  }

  u3z(wit);
}

static void
_cue_bench(void)
{
  struct timeval b4, f2, d0;
  c3_w  mil_w, i_w, max_w = 20000;
  u3_atom vat = u3ke_jam(_ames_writ_ex());

  fprintf(stderr, "\r\ncue microbenchmark:\r\n");

  {
    gettimeofday(&b4, 0);

    for ( i_w = 0; i_w < max_w; i_w++ ) {
      u3z(u3s_cue(vat));
    }

    gettimeofday(&f2, 0);
    timersub(&f2, &b4, &d0);
    mil_w = (d0.tv_sec * 1000) + (d0.tv_usec / 1000);
    fprintf(stderr, "  cue og: %u ms\r\n", mil_w);
  }

  {
    gettimeofday(&b4, 0);

    for ( i_w = 0; i_w < max_w; i_w++ ) {
      u3z(u3s_cue_atom(vat));
    }

    gettimeofday(&f2, 0);
    timersub(&f2, &b4, &d0);
    mil_w = (d0.tv_sec * 1000) + (d0.tv_usec / 1000);
    fprintf(stderr, "  cue atom: %u ms\r\n", mil_w);
  }

  //  NB: runs 1/8th the number of times
  //
  {
    gettimeofday(&b4, 0);

    {
      c3_w  len_w = u3r_met(3, vat);
      // XX assumes little-endian
      //
      c3_y* byt_y = ( c3y == u3a_is_cat(vat) )
                  ? (c3_y*)&vat
                  : (c3_y*)((u3a_atom*)u3a_to_ptr(vat))->buf_w;

      for ( i_w = 0; i_w < max_w / 8; i_w++ ) {
        u3z(u3s_cue_xeno(len_w, byt_y));
      }
    }

    gettimeofday(&f2, 0);
    timersub(&f2, &b4, &d0);
    mil_w = (d0.tv_sec * 1000) + (d0.tv_usec / 1000);
    fprintf(stderr, "  cue xeno: %u ms (estimated)\r\n", mil_w * 8);
  }

  {
    gettimeofday(&b4, 0);

    {
      ur_dict32_t dic_u = {0};
      u3_noun       out;

      c3_w  len_w = u3r_met(3, vat);
      // XX assumes little-endian
      //
      c3_y* byt_y = ( c3y == u3a_is_cat(vat) )
                  ? (c3_y*)&vat
                  : (c3_y*)((u3a_atom*)u3a_to_ptr(vat))->buf_w;

      ur_dict32_grow((ur_root_t*)0, &dic_u, ur_fib10, ur_fib11);

      for ( i_w = 0; i_w < max_w; i_w++ ) {
        u3s_cue_xeno_unsafe(&dic_u, len_w, byt_y, &out);
        u3z(out);
        ur_dict32_wipe(&dic_u);
      }

      ur_dict_free((ur_dict_t*)&dic_u);
    }

    gettimeofday(&f2, 0);
    timersub(&f2, &b4, &d0);
    mil_w = (d0.tv_sec * 1000) + (d0.tv_usec / 1000);
    fprintf(stderr, "  cue xeno unsafe: %u ms\r\n", mil_w);
  }

  {
    gettimeofday(&b4, 0);

    {
      c3_w  len_w = u3r_met(3, vat);
      // XX assumes little-endian
      //
      c3_y* byt_y = ( c3y == u3a_is_cat(vat) )
                  ? (c3_y*)&vat
                  : (c3_y*)((u3a_atom*)u3a_to_ptr(vat))->buf_w;

      for ( i_w = 0; i_w < max_w; i_w++ ) {
        ur_cue_test(len_w, byt_y);
      }
    }

    gettimeofday(&f2, 0);
    timersub(&f2, &b4, &d0);
    mil_w = (d0.tv_sec * 1000) + (d0.tv_usec / 1000);
    fprintf(stderr, "  cue test: %u ms\r\n", mil_w);
  }

  {
    gettimeofday(&b4, 0);

    {
      ur_dict_t dic_u = {0};
      u3_noun       out;

      c3_w  len_w = u3r_met(3, vat);
      // XX assumes little-endian
      //
      c3_y* byt_y = ( c3y == u3a_is_cat(vat) )
                  ? (c3_y*)&vat
                  : (c3_y*)((u3a_atom*)u3a_to_ptr(vat))->buf_w;

      ur_dict_grow((ur_root_t*)0, &dic_u, ur_fib10, ur_fib11);

      for ( i_w = 0; i_w < max_w; i_w++ ) {
        ur_cue_test_unsafe(&dic_u, len_w, byt_y);
        ur_dict_wipe(&dic_u);
      }

      ur_dict_free(&dic_u);
    }

    gettimeofday(&f2, 0);
    timersub(&f2, &b4, &d0);
    mil_w = (d0.tv_sec * 1000) + (d0.tv_usec / 1000);
    fprintf(stderr, "  cue test unsafe: %u ms\r\n", mil_w);
  }

  {
    gettimeofday(&b4, 0);

    {
      ur_root_t* rot_u = ur_hcon_init();
      ur_nref      ref;
      c3_w  len_w = u3r_met(3, vat);
      // XX assumes little-endian
      //
      c3_y* byt_y = ( c3y == u3a_is_cat(vat) )
                  ? (c3_y*)&vat
                  : (c3_y*)((u3a_atom*)u3a_to_ptr(vat))->buf_w;

      for ( i_w = 0; i_w < max_w; i_w++ ) {
        ur_cue(rot_u, len_w, byt_y, &ref);
      }

      ur_hcon_free(rot_u);
    }

    gettimeofday(&f2, 0);
    timersub(&f2, &b4, &d0);
    mil_w = (d0.tv_sec * 1000) + (d0.tv_usec / 1000);
    fprintf(stderr, "  cue cons: %u ms\r\n", mil_w);
  }

  {
    gettimeofday(&b4, 0);

    {
      ur_root_t* rot_u;
      ur_nref      ref;
      c3_w  len_w = u3r_met(3, vat);
      // XX assumes little-endian
      //
      c3_y* byt_y = ( c3y == u3a_is_cat(vat) )
                  ? (c3_y*)&vat
                  : (c3_y*)((u3a_atom*)u3a_to_ptr(vat))->buf_w;

      for ( i_w = 0; i_w < max_w; i_w++ ) {
        rot_u = ur_hcon_init();
        ur_cue(rot_u, len_w, byt_y, &ref);
        ur_hcon_free(rot_u);
      }
    }

    gettimeofday(&f2, 0);
    timersub(&f2, &b4, &d0);
    mil_w = (d0.tv_sec * 1000) + (d0.tv_usec / 1000);
    fprintf(stderr, "  cue re-cons: %u ms\r\n", mil_w);
  }

  u3z(vat);
}

static u3_noun
_cue_loop(u3_atom a)
{
  c3_w i_w, max_w = 20000;

  for ( i_w = 0; i_w < max_w; i_w++ ) {
    u3z(u3s_cue(a));
  }

  return u3_blip;
}

static u3_noun
_cue_atom_loop(u3_atom a)
{
  c3_w i_w, max_w = 20000;

  for ( i_w = 0; i_w < max_w; i_w++ ) {
    u3z(u3s_cue_atom(a));
  }

  return u3_blip;
}

static void
_cue_soft_bench(void)
{
  struct timeval b4, f2, d0;
  u3_atom vat = u3ke_jam(_ames_writ_ex());
  c3_w  mil_w;

  fprintf(stderr, "\r\ncue virtual microbenchmark:\r\n");

  {
    gettimeofday(&b4, 0);

    u3z(u3m_soft(0, _cue_loop, u3k(vat)));

    gettimeofday(&f2, 0);
    timersub(&f2, &b4, &d0);
    mil_w = (d0.tv_sec * 1000) + (d0.tv_usec / 1000);
    fprintf(stderr, "  cue virtual og: %u ms\r\n", mil_w);
  }

  {
    gettimeofday(&b4, 0);

    u3z(u3m_soft(0, _cue_atom_loop, u3k(vat)));

    gettimeofday(&f2, 0);
    timersub(&f2, &b4, &d0);
    mil_w = (d0.tv_sec * 1000) + (d0.tv_usec / 1000);
    fprintf(stderr, "  cue virtual atom: %u ms\r\n", mil_w);
  }

  u3z(vat);
}

/* main(): run all benchmarks
*/
int
main(int argc, char* argv[])
{
  _setup();

  _jam_bench();
  _cue_bench();
  _cue_soft_bench();

  //  GC
  //
  u3m_grab(u3_none);

  return 0;
}