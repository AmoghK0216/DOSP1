actor Main
  new create(env: Env) =>
    try
      let args = env.args
      let n = args(1)?.string().u64()?
      let k = args(2)?.string().u64()?
      
      // find_solutions(env, n, k)
      let work_unit_size : U64 = 10
      Boss(n, k, work_unit_size, env)
    else
      env.out.print("Error failed")
    end

actor Boss
  let _n : U64
  let _k : U64
  let _work_unit_size : U64
  var _solutions: Array[U64]
  var _pending_workers: U64
  var _env : Env

  new create(n : U64, k : U64, work_unit_size : U64, env: Env) =>
      _n = n
      _k = k
      _work_unit_size = work_unit_size
      _solutions = Array[U64].create(0)
      _pending_workers = 0
      _env = env
      assign_work()
      
  be assign_work() =>
    var start : U64 = 1
    var ending : U64 = _n
    var index : U64 = 0
    while start <= _n do
      if (start + (_work_unit_size - 1)) <= _n then
        ending = start + (_work_unit_size - 1)
      else
        ending = _n
      end
      _pending_workers = _pending_workers + 1
      index = index + 1
      Worker(this, start, ending, _k)
      start = ending + 1
    end
  
  be report_solution(solution : U64) =>
    _solutions.push(solution)
  
  be worker_task_finished() =>
    _pending_workers = _pending_workers - 1
    if _pending_workers == 0 then
      display_solutions()
    end
  
  fun display_solutions() =>
    for name in _solutions.values() do
      _env.out.print(name.string())
    end

actor Worker
  var _boss : Boss
  let _start : U64
  let _end : U64
  let _k : U64

  new create(boss : Boss, start : U64, ending : U64, k : U64) =>
    _boss = boss
    _start = start
    _end = ending
    _k = k
    computeSolution()
  
  fun ref computeSolution() =>
    var i: U64 = _start
    while i <= _end do
      if is_perfect_square_sum(i, _k) then
        _boss.report_solution(i)
      end
      i = i + 1
    end
    _boss.worker_task_finished()

  fun is_perfect_square_sum(start: U64, length: U64): Bool =>
    var sum: U64 = 0
    var i: U64 = 0
    while i < length do
      sum = sum + ((start + i) * (start + i))
      i = i + 1
    end
    var check : U64 = sum.f64().sqrt().u64() * sum.f64().sqrt().u64()
    check == sum

  



