from devops_capstone import devops_capstone


def test_fib() -> None:
    assert devops_capstone.fib(0) == 0
    assert devops_capstone.fib(1) == 1
    assert devops_capstone.fib(2) == 1
    assert devops_capstone.fib(3) == 2
    assert devops_capstone.fib(4) == 3
    assert devops_capstone.fib(5) == 5
    assert devops_capstone.fib(10) == 55
