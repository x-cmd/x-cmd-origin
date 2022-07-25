# TO Yuhang: Demo for recursive

function fib(n){
    if (n<=2)  return 1
    return fib(n-1) + fib(n-2)
}

BEGIN{
    print fib(10)
}
