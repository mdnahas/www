(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2016     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

open Names
open Locus
open Genredexpr
open Misctypes
open Tactypes
open Proofview

(** Local reimplementations of tactics variants from Coq *)

val apply : advanced_flag -> evars_flag ->
  EConstr.constr with_bindings tactic list ->
  (Id.t * intro_pattern option) option -> unit tactic

type induction_clause =
  EConstr.constr with_bindings tactic destruction_arg *
  intro_pattern_naming option *
  or_and_intro_pattern option *
  clause option

val induction_destruct : rec_flag -> evars_flag ->
  induction_clause list -> EConstr.constr with_bindings option -> unit tactic

type rewriting =
  bool option *
  multi *
  EConstr.constr with_bindings tactic

val rewrite :
  evars_flag -> rewriting list -> clause -> unit tactic option -> unit tactic

val simpl : evaluable_global_reference glob_red_flag ->
  (Pattern.constr_pattern * occurrences_expr) option -> clause -> unit tactic

val vm : (Pattern.constr_pattern * occurrences_expr) option -> clause -> unit tactic

val native : (Pattern.constr_pattern * occurrences_expr) option -> clause -> unit tactic
