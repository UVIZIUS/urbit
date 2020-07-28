#include <inttypes.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>

#include <limits.h>

#include <murmur3.h>

#include "noun/hashcons.h"

ur_mug
ur_mug_bytes(const uint8_t *byt, uint64_t len)
{
  uint32_t seed = 0xcafebabe;
  ur_mug    mug;

  while ( 1 ) {
    uint32_t raw;
    MurmurHash3_x86_32(byt, len, seed, &raw);
    mug = (raw >> 31) ^ ( ur_mask_31(raw) );

    if ( 0 == mug ) {
      seed++;
    }
    else {
      return mug;
    }
  }
}

ur_mug
ur_mug32(uint32_t x)
{
  uint8_t byt[4] = {
    ur_mask_8(x >>  0),
    ur_mask_8(x >>  8),
    ur_mask_8(x >> 16),
    ur_mask_8(x >> 24)
  };

  return ur_mug_bytes(byt, ur_met3_32(x));
}

ur_mug
ur_mug64(uint64_t x)
{
  uint8_t byt[8] = {
    ur_mask_8(x >>  0),
    ur_mask_8(x >>  8),
    ur_mask_8(x >> 16),
    ur_mask_8(x >> 24),
    ur_mask_8(x >> 32),
    ur_mask_8(x >> 40),
    ur_mask_8(x >> 48),
    ur_mask_8(x >> 56)
  };

  return ur_mug_bytes(byt, ur_met3_64(x));
}

ur_mug
ur_mug_both(ur_mug hed, ur_mug tal)
{
  return ur_mug32(hed ^ (0x7fffffff ^ tal));
}

ur_mug
ur_nref_mug(ur_root_t *r, ur_nref ref)
{
  switch ( ur_nref_tag(ref) ) {
    default: assert(0);

    case ur_direct: return ur_mug64(ref);
    case ur_iatom:  return r->atoms.mugs[ur_nref_idx(ref)];
    case ur_icell:  return r->cells.mugs[ur_nref_idx(ref)];
  }
}

ur_bool_t
ur_deep(ur_nref ref)
{
  return ur_icell == ur_nref_tag(ref);
}

ur_nref
ur_head(ur_root_t *r, ur_nref ref)
{
  assert( ur_deep(ref) );
  return r->cells.heads[ur_nref_idx(ref)];
}

ur_nref
ur_tail(ur_root_t *r, ur_nref ref)
{
  assert( ur_deep(ref) );
  return r->cells.tails[ur_nref_idx(ref)];
}

void
ur_dict64_grow(ur_root_t *r, ur_dict64_t *dict, uint64_t prev, uint64_t size)
{
  ur_pail64_t *buckets, *old_buckets = dict->buckets;
  uint64_t old_size = dict->size;
  uint64_t next = prev + size;
  uint64_t i;

  buckets = calloc(next, sizeof(*buckets));

  for ( i = 0; i < old_size; i++ ) {
    ur_pail64_t *old_bucket = &(old_buckets[i]);
    uint64_t old_fill = old_bucket->fill;
    uint64_t j;

    for ( j = 0; j < old_fill; j++ ) {
      ur_nref ref = (ur_nref)old_bucket->data[old_fill];
      ur_mug  mug = ur_nref_mug(r, ref);
      
      ur_pail64_t *bucket = &(buckets[ mug % next ]);
      uint64_t   new_fill = bucket->fill;

      if( 10 == new_fill ) {
        free(buckets);
        return ur_dict64_grow(r, dict, size, next);
      }

      bucket->data[new_fill] = (uint64_t)ref;
      bucket->fill = 1 + new_fill;
    }
  }

  free(old_buckets);

  dict->prev = size;
  dict->size = next;
  dict->buckets = buckets;
}

void
ur_atoms_grow(ur_atoms_t *atoms)
{
  uint64_t   prev = atoms->prev;
  uint64_t   size = atoms->size;
  uint64_t   next = prev + size;
  uint8_t **bytes = atoms->bytes;
  uint64_t  *lens = atoms->lens;
  ur_mug    *mugs = atoms->mugs;

  atoms->bytes = malloc(next * (sizeof(*atoms->bytes)
                              + sizeof(*atoms->lens)
                              + sizeof(*atoms->mugs)));
  assert( atoms->bytes );

  atoms->lens  = (void*)(atoms->bytes + (next * sizeof(*atoms->bytes)));
  atoms->mugs  = (void*)(atoms->lens  + (next * sizeof(*atoms->lens)));

  if ( bytes ) {
    memcpy(atoms->bytes, bytes, size * (sizeof(*bytes)));
    memcpy(atoms->lens, lens, size * (sizeof(*lens)));
    memcpy(atoms->mugs, mugs, size * (sizeof(*mugs)));

    free(bytes);
  }
}

void
ur_cells_grow(ur_cells_t *cells)
{
  uint64_t  prev = cells->prev;
  uint64_t  size = cells->size;
  uint64_t  next = prev + size;
  ur_nref *heads = cells->heads;
  ur_nref *tails = cells->tails;
  ur_mug   *mugs = cells->mugs;

  cells->heads = malloc(next * (sizeof(*cells->heads)
                              + sizeof(*cells->heads)
                              + sizeof(*cells->mugs)));
  assert( cells->heads );

  cells->tails = (void*)(cells->heads + (next * sizeof(*cells->heads)));
  cells->mugs  = (void*)(cells->tails + (next * sizeof(*cells->tails)));

  if ( heads ) {
    memcpy(cells->heads, heads, size * (sizeof(*heads)));
    memcpy(cells->tails, tails, size * (sizeof(*tails)));
    memcpy(cells->mugs, mugs, size * (sizeof(*mugs)));

    free(heads);
  }
}

void
ur_bytes(ur_root_t *r, ur_nref ref, uint8_t **byt, uint64_t *len)
{
  assert( !ur_deep(ref) );
  switch ( ur_nref_tag(ref) ) {
    default: assert(0);

    case ur_direct: {
      *len = ur_met3_64(ref);
      //  XX little-endian
      //
      *byt = (uint8_t*)&ref;
    } break;

    case ur_iatom: {
      uint64_t idx = ur_nref_idx(ref);
      *len = r->atoms.lens[idx];
      *byt = r->atoms.bytes[idx];
    } break;
  }
}

static ur_nref
_coin_unsafe(ur_atoms_t *atoms, ur_mug mug, uint8_t *byt, uint64_t len)
{
  uint64_t fill = atoms->fill;
  ur_nref   tom = ( fill & ((uint64_t)ur_iatom << 62) );
  uint8_t *copy = malloc(len);

  //  XX necessary?
  //
  assert( 62 >= ur_met0_64(fill) );

  assert(copy);
  memcpy(copy, byt, len);

  atoms->bytes[fill] = copy;
  atoms->lens[fill] = len;
  atoms->mugs[fill] = mug;

  return tom;
}

static ur_nref
_cons_unsafe(ur_cells_t *cells, ur_mug mug, ur_nref hed, ur_nref tal)
{
  uint64_t fill = cells->fill;
  ur_nref   cel = ( fill & ((uint64_t)ur_icell << 62) );

  //  XX necessary?
  //
  assert( 62 >= ur_met0_64(fill) );

  cells->mugs[fill]  = mug;
  cells->heads[fill] = hed;
  cells->tails[fill] = tal;
  cells->fill = 1 + fill;

  return cel;
}

ur_nref
ur_coin_bytes(ur_root_t *r, uint8_t *byt, uint64_t len)
{
  ur_atoms_t *atoms = &(r->atoms);
  ur_dict64_t *dict = &(atoms->dict);
  ur_mug        mug = ur_mug_bytes(byt, len);

  while ( 1 ) {
    uint64_t        idx = ( mug % dict->size );
    ur_pail64_t *bucket = &(dict->buckets[idx]);
    uint8_t   i, b_fill = bucket->fill;
    ur_nref tom;

    for ( i = 0; i < b_fill; i++ ) {
      uint8_t *t_byt;
      uint64_t t_len;
      tom = (ur_nref)bucket->data[i];

      ur_bytes(r, tom, &t_byt, &t_len);

      if (  (t_len == len)
         && (0 == memcmp(t_byt, byt, len)) )
      {
        return tom;
      }
    }

    if ( 10 == b_fill ) {
      ur_dict64_grow(r, dict, dict->prev, dict->size);
      continue;
    }

    if ( atoms->fill == atoms->size ) {
      ur_atoms_grow(atoms);
    }

    tom = _coin_unsafe(atoms, mug, byt, len);
    
    bucket->data[b_fill] = (uint64_t)tom;
    bucket->fill = 1 + b_fill;

    return tom;
  }
}

ur_nref
ur_coin64(ur_root_t *r, uint64_t n)
{
  if ( ur_direct == ur_nref_tag(n) ) {
    return n;
  }
  else {
    //  XX little-endian
    //
    return ur_coin_bytes(r, (uint8_t*)&n, ur_met3_64(n));
  }
}

ur_nref
ur_cons(ur_root_t *r, ur_nref hed, ur_nref tal)
{
  ur_cells_t *cells = &(r->cells);
  ur_dict64_t *dict = &(cells->dict);
  ur_mug mug        = ur_mug_both(ur_nref_mug(r, hed),
                                  ur_nref_mug(r, tal));

  while ( 1 ) {
    uint64_t        idx = ( mug % cells->size );
    ur_pail64_t *bucket = &(dict->buckets[idx]);
    uint8_t   i, b_fill = bucket->fill;
    ur_nref cel;

    for ( i = 0; i < b_fill; i++ ) {
      cel = (ur_nref)bucket->data[i];

      if (  (hed == ur_head(r, cel))
         && (tal == ur_tail(r, cel)) )
      {
        return cel;
      }
    }

    if ( 10 == b_fill ) {
      ur_dict64_grow(r, dict, dict->prev, dict->size);
      continue;
    }

    if ( cells->fill == cells->size ) {
      ur_cells_grow(cells);
    }

    cel = _cons_unsafe(cells, mug, hed, tal);

    bucket->data[b_fill] = (uint64_t)cel;
    bucket->fill = 1 + b_fill;

    return cel;
  }
}

ur_root_t*
ur_hcon_init(void)
{
  ur_root_t *r = calloc(1, sizeof(*r));
  assert( r );

  {
    ur_dict64_t *dict;
    uint64_t fib11 = 89, fib12 = 144;

    //  allocate atom storage
    //
    r->atoms.prev  = fib11;
    r->atoms.size  = fib12;
    ur_atoms_grow(&(r->atoms));

    //  allocate atom hashtable
    //
    dict = &(r->atoms.dict);
    ur_dict64_grow(r, dict, fib11, fib12);

    //  allocate cell storage
    //
    r->cells.prev  = fib11;
    r->cells.size  = fib12;
    ur_cells_grow(&(r->cells));

    //  allocate cell hashtable
    //
    dict = &(r->cells.dict);
    ur_dict64_grow(r, dict, fib11, fib12);
  }

  return r;
}