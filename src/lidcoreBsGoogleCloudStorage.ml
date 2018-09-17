open BsAsyncMonad.Callback
open LidcoreBsNode

module Storage = struct
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

  external init : config -> t = "@google-cloud/storage" [@@bs.module]

  (* See: https://github.com/firebase/functions-samples/issues/269#issuecomment-342796212 *)
  type reqOps = {
    mutable forever: bool
  } [@@bs.deriving abstract]

  type interceptor = {
    request: reqOps -> reqOps;
  } [@@bs.deriving abstract]

  external interceptors : t -> interceptor array = "" [@@bs.get]

  let default_config = config ()

  let init ?(config=default_config) () =
    let gcs = init config in
    let request ops =
      foreverSet ops false;
      ops
    in
    let interceptor =
      interceptor ~request
    in
    ignore(Js.Array.push interceptor (interceptors gcs));
    gcs

  external bucket : t -> string -> bucket = "" [@@bs.send]
  external file : bucket -> string -> file = "" [@@bs.send]
  external createReadStream : file -> Stream.readable = "" [@@bs.send]
  external createWriteStream : file -> Stream.writable = "" [@@bs.send]
  external getSignedUrl : file -> url_config -> string callback -> unit = "" [@@bs.send]
  let getSignedUrl ~config file cb =
    getSignedUrl file config cb
end
