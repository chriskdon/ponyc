use "collections"
use "random"
use "time"
use @printf[I32](fmt: Pointer[U8] tag, ...)

actor Main
  new create(env: Env) =>
    let time_to_run_in_minutes: U64 = 20
    let run_until_millis = Time.millis() + (time_to_run_in_minutes * 60 * 1000)

    let timers = Timers
    var previous: (ShortLived | None) = None

    for i in Range(0,10) do
      previous = ShortLived(run_until_millis, previous, timers)
    end

actor ShortLived
  let _timers: Timers
  //let _timer: Timer tag

  let _ttl: U64
  var _previous: (ShortLived | None) = None

  new create(ttl: U64, previous: (ShortLived | None), timers: Timers) =>
    _ttl = ttl
    _previous = previous
    _timers = timers
    let t = Timer(Notify(this, _ttl), 5_000_000, 5_000_000)
    //_timer = t
    _timers(consume t)

  be spawn() =>
    ShortLived(_ttl, this, _timers)

  be chat() =>
    match _previous
    | let p: ShortLived => p.chat()
    end

  be cancel() =>
    //_timers.cancel(_timer)
    _previous = None

class Notify is TimerNotify
  let _s: ShortLived
  let _ttl: U64
  let _rand: Rand

  new iso create(s: ShortLived, ttl: U64) =>
    _s = s
    _ttl = ttl
    _rand = Rand

  fun ref apply(timer: Timer, count: U64): Bool =>
    if _ttl > Time.millis() then
      let r = _rand.int(1000)
      if r == 0 then
        _s.spawn()
        return true
      elseif r < 998 then
        _s.chat()
        return true
      end
    end

    _s.cancel()
    false
