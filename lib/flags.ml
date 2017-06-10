(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2017     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

let with_modified_ref r nf f x =
  let old_ref = !r in r := nf !r;
  try let res = f x in r := old_ref; res
  with reraise ->
    let reraise = Backtrace.add_backtrace reraise in
    r := old_ref;
    Exninfo.iraise reraise

let with_option o f x = with_modified_ref o (fun _ -> true) f x
let without_option o f x = with_modified_ref o (fun _ -> false) f x
let with_extra_values o l f x = with_modified_ref o (fun ol -> ol@l) f x

let with_options ol f x =
  let vl = List.map (!) ol in
  let () = List.iter (fun r -> r := true) ol in
  try
    let r = f x in
    let () = List.iter2 (:=) ol vl in r
  with reraise ->
    let reraise = Backtrace.add_backtrace reraise in
    let () = List.iter2 (:=) ol vl in
    Exninfo.iraise reraise

let boot = ref false

let record_aux_file = ref false

let test_mode = ref false

let async_proofs_worker_id = ref "master"
let async_proofs_is_worker () = !async_proofs_worker_id <> "master"

let debug = ref false

let in_debugger = ref false
let in_toplevel = ref false

let profile = false

let ide_slave = ref false
let ideslave_coqtop_flags = ref None

let time = ref false

let raw_print = ref false

let univ_print = ref false

let we_are_parsing = ref false

(* Compatibility mode *)

(* Current means no particular compatibility consideration.
   For correct comparisons, this constructor should remain the last one. *)

type compat_version = VOld | V8_5 | V8_6 | V8_7 | Current

let compat_version = ref Current

let version_compare v1 v2 = match v1, v2 with
  | VOld, VOld -> 0
  | VOld, _ -> -1
  | _, VOld -> 1
  | V8_5, V8_5 -> 0
  | V8_5, _ -> -1
  | _, V8_5 -> 1
  | V8_6, V8_6 -> 0
  | V8_6, _ -> -1
  | _, V8_6 -> 1
  | V8_7, V8_7 -> 0
  | V8_7, _ -> -1
  | _, V8_7 -> 1
  | Current, Current -> 0

let version_strictly_greater v = version_compare !compat_version v > 0
let version_less_or_equal v = not (version_strictly_greater v)

let pr_version = function
  | VOld -> "old"
  | V8_5 -> "8.5"
  | V8_6 -> "8.6"
  | V8_7 -> "8.7"
  | Current -> "current"

(* Translate *)
let beautify = ref false
let beautify_file = ref false

(* Silent / Verbose *)
let quiet = ref false
let silently f x = with_option quiet f x
let verbosely f x = without_option quiet f x

let if_silent f x = if !quiet then f x
let if_verbose f x = if not !quiet then f x

let auto_intros = ref true
let make_auto_intros flag = auto_intros := flag
let is_auto_intros () = !auto_intros

let universe_polymorphism = ref false
let make_universe_polymorphism b = universe_polymorphism := b
let is_universe_polymorphism () = !universe_polymorphism

let local_polymorphic_flag = ref None
let use_polymorphic_flag () = 
  match !local_polymorphic_flag with 
  | Some p -> local_polymorphic_flag := None; p
  | None -> is_universe_polymorphism ()
let make_polymorphic_flag b =
  local_polymorphic_flag := Some b

let polymorphic_inductive_cumulativity = ref false
let make_polymorphic_inductive_cumulativity b = polymorphic_inductive_cumulativity := b
let is_polymorphic_inductive_cumulativity () = !polymorphic_inductive_cumulativity

(** [program_mode] tells that Program mode has been activated, either
    globally via [Set Program] or locally via the Program command prefix. *)

let program_mode = ref false
let is_program_mode () = !program_mode

let warn = ref true
let make_warn flag = warn := flag;  ()
let if_warn f x = if !warn then f x

(* Flags for external tools *)

let browser_cmd_fmt =
 try
  let coq_netscape_remote_var = "COQREMOTEBROWSER" in
  Sys.getenv coq_netscape_remote_var
 with
  Not_found -> Coq_config.browser

let is_standard_doc_url url =
  let wwwcompatprefix = "http://www.lix.polytechnique.fr/coq/" in
  let n = String.length Coq_config.wwwcoq in
  let n' = String.length Coq_config.wwwrefman in
  url = Coq_config.localwwwrefman ||
  url = Coq_config.wwwrefman ||
  url = wwwcompatprefix ^ String.sub Coq_config.wwwrefman n (n'-n)

(* Options for changing coqlib *)
let coqlib_spec = ref false
let coqlib = ref "(not initialized yet)"

(* Options for changing ocamlfind (used by coqmktop) *)
let ocamlfind_spec = ref false
let ocamlfind = ref Coq_config.camlbin

(* Options for changing camlp4bin (used by coqmktop) *)
let camlp4bin_spec = ref false
let camlp4bin = ref Coq_config.camlp4bin

(* Level of inlining during a functor application *)

let default_inline_level = 100
let inline_level = ref default_inline_level
let set_inline_level = (:=) inline_level
let get_inline_level () = !inline_level

(* Native code compilation for conversion and normalization *)
let native_compiler = ref false

(* Print the mod uid associated to a vo file by the native compiler *)
let print_mod_uid = ref false

let tactic_context_compat = ref false
let profile_ltac = ref false
let profile_ltac_cutoff = ref 2.0

let dump_bytecode = ref false
let set_dump_bytecode = (:=) dump_bytecode
let get_dump_bytecode () = !dump_bytecode
