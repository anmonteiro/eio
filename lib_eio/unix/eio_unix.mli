(** Extension of {!Eio} for integration with OCaml's [Unix] module.

    Note that OCaml's [Unix] module is not safe, and therefore care must be taken when using these functions.
    For example, it is possible to leak file descriptors this way, or to use them after they've been closed,
    allowing one module to corrupt a file belonging to an unrelated module. *)

val await_readable : Unix.file_descr -> unit
(** [await_readable fd] blocks until [fd] is readable (or has an error). *)

val await_writable : Unix.file_descr -> unit
(** [await_writable fd] blocks until [fd] is writable (or has an error). *)

(** Get a [Unix.file_descr] from an Eio object. *)
module FD : sig
  val peek : #Eio.Generic.t -> Unix.file_descr option
  (** [peek x] is the Unix file descriptor underlying [x], if any.
      The caller must ensure that they do not continue to use the result after [x] is closed. *)

  val take : #Eio.Generic.t -> Unix.file_descr option
  (** [take x] is like [peek], but also marks [x] as closed on success (without actually closing the FD).
      [x] can no longer be used after this, and the caller is responsible for closing the FD. *)
end

(** Convert between Eio.Net.Ipaddr and Unix.inet_addr. *)
module Ipaddr : sig
  (** Internally, these are actually the same type, so these are just casts. *)

  val to_unix : [< `V4 | `V6] Eio.Net.Ipaddr.t -> Unix.inet_addr
  val of_unix : Unix.inet_addr -> Eio.Net.Ipaddr.v4v6
end

(** API for Eio backends only. *)
module Private : sig
  open Eio.Private.Effect

  type _ Eio.Generic.ty += Unix_file_descr : [`Peek | `Take] -> Unix.file_descr Eio.Generic.ty
  (** See {!FD}. *)

  type _ eff += 
    | Await_readable : Unix.file_descr -> unit eff      (** See {!await_readable} *)
    | Await_writable : Unix.file_descr -> unit eff      (** See {!await_writable} *)
end
