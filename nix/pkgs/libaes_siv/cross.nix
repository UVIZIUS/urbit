{ env_name, env, ..e }:

env.make_derivation {
  name    = "libaes_siv";
  src     = ../../../pkg/libaes_siv;
  builder = ./builder.sh;

  cross_inputs = [ env.openssl ];

  CC = "${env.host}-gcc";
  AR = "${env.host}-ar";
}
