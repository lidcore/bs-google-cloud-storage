open BsAsyncMonad
open LidcoreBsNode

module Storage : sig
  type t
  type bucket
  type file

  type config = {
    projectId : string [@bs.optional]
  } [@@bs.deriving abstract]

  type url_config = {
    action:  string;
    expires: int;
  } [@@bs.deriving abstract]

  val init : ?config:config -> unit -> t
  val bucket : t -> string -> bucket
  val file : bucket -> string -> file
  val createReadStream : file -> Stream.readable
  val createWriteStream : file -> Stream.writable
  val getSignedUrl : config:url_config -> file -> string Callback.t
end
